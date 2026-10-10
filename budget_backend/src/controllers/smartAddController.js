const AiImport = require('../models/AiImport');
const Transaction = require('../models/Transaction');
const Category = require('../models/Category');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');
const dates = require('../utils/dates');
const askAiHub = require('../services/aiHub');
const parseWithRules = require('../services/rulesParser');
const { smartAddDailyLimit } = require('../config');

const INPUT_TYPES = ['text', 'voice', 'image', 'pdf'];
const MAX_TEXT = 20000;
// Vercel rejects request bodies over 4.5 MB; base64 adds a third on top of the file size.
const MAX_FILE_BASE64 = 4 * 1024 * 1024;
const FILE_TYPES = {
  image: ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'],
  pdf: ['application/pdf'],
};
const MAX_ENTRIES = 80;

// Same checks the Add sheet gets, plus rupees -> paise. Entries that fail are dropped.
const cleanEntries = (raw, categories, latestDay) => {
  const keys = new Set(categories.map((c) => `${c.type}:${c.key}`));
  const clean = [];

  for (const e of raw) {
    if (!e || typeof e !== 'object') continue;
    const amount = Number(e.amount);
    const category = typeof e.category === 'string' ? e.category.trim().toLowerCase() : '';
    const note = typeof e.note === 'string' ? e.note.trim().slice(0, 40) : '';

    if (e.type !== 'income' && e.type !== 'expense') continue;
    if (!Number.isFinite(amount) || amount <= 0) continue;
    const paise = Math.round(amount * 100);
    if (paise < 1 || paise > 9999999999) continue;
    if (!keys.has(`${e.type}:${category}`)) continue;
    if (!dates.isDay(e.date) || e.date > latestDay) continue;

    clean.push({ type: e.type, amount: paise, category, note, date: e.date });
    if (clean.length === MAX_ENTRIES) break;
  }
  return clean;
};

exports.smartAdd = asyncHandler(async (req, res) => {
  const body = req.body || {};
  const { inputType, text, today } = body;
  // Form upload: every field arrives as text and the photo or PDF as `file`. JSON: `file` is { mimeType, data (base64) }.
  const tzOffsetMinutes = Number.parseInt(body.tzOffsetMinutes, 10);
  const file = req.file ? { mimeType: req.file.mimetype, data: req.file.buffer.toString('base64') } : body.file;

  if (!INPUT_TYPES.includes(inputType)) throw httpError(400, 'inputType must be text, voice, image or pdf');
  if (!dates.isDay(today)) throw httpError(400, 'today must be YYYY-MM-DD');
  const latestDay = dates.latestAllowedDay(today);

  // Photos and PDFs are read by AI as files; typed and spoken text (speech-to-text happens in the app) is sent as text.
  const isFile = inputType === 'image' || inputType === 'pdf';
  if (isFile) {
    if (!file || typeof file.data !== 'string' || !file.data) throw httpError(400, 'file is required: { mimeType, data (base64) }');
    if (!FILE_TYPES[inputType].includes(file.mimeType)) {
      throw httpError(400, `file.mimeType must be ${FILE_TYPES[inputType].join(', ')}`);
    }
    if (file.data.length > MAX_FILE_BASE64) throw httpError(413, 'File is too large. Keep it under about 3 MB.');
  } else {
    if (typeof text !== 'string' || !text.trim()) throw httpError(400, 'text is required');
    if (text.length > MAX_TEXT) throw httpError(400, `text can be at most ${MAX_TEXT} characters`);
  }

  // The user's own day: midnight of `today` in their time zone (minutes ahead of UTC, e.g. 330 for IST).
  const offset = Number.isFinite(tzOffsetMinutes) ? tzOffsetMinutes : 0;
  const startOfToday = new Date(Date.parse(`${today}T00:00:00Z`) - offset * 60 * 1000);
  const runsToday = await AiImport.countDocuments({ user: req.user._id, createdAt: { $gte: startOfToday } });
  if (runsToday >= smartAddDailyLimit) throw httpError(429, 'Daily Smart add limit reached. Try again tomorrow.');

  const categories = await Category.find({ isActive: true }, 'type key keywords').lean();
  const keysByType = (type) => categories.filter((c) => c.type === type).map((c) => c.key);

  let parser = 'ai';
  let provider = null;
  let documentType = null;
  let entries = [];

  const aiResult = await askAiHub({
    today: latestDay,
    inputType,
    text: isFile ? undefined : text,
    file: isFile ? { mimeType: file.mimeType, data: file.data } : undefined,
    categories: { expense: keysByType('expense'), income: keysByType('income') },
  });
  const aiOk = Boolean(aiResult) && !aiResult.error;
  if (aiOk) {
    entries = cleanEntries(aiResult.entries, categories, latestDay);
    provider = aiResult.provider;
    const kind = String(aiResult.documentType || '').toLowerCase();
    documentType = ['receipt', 'statement'].includes(kind) ? kind : null;
  }

  // The keyword parser can only read text, so it is the fallback for typed and spoken notes only.
  if (entries.length === 0 && !isFile) {
    parser = 'rules';
    provider = null;
    documentType = null;
    entries = cleanEntries(parseWithRules(text, latestDay, categories), categories, latestDay);
  }

  const run = {
    user: req.user._id,
    inputType,
    documentType,
    // Bill and statement text is never stored.
    inputText: isFile ? null : text.slice(0, 500),
    parser,
    provider,
  };

  if (entries.length === 0) {
    const aiDown = isFile && !aiOk;
    await AiImport.create({ ...run, status: 'failed', error: aiDown ? aiResult.error : 'No amount found' });
    if (aiDown) throw httpError(502, `Could not read the file right now (${aiResult.error}). Try again, or add it manually.`);
    throw httpError(422, 'Could not find any amount. Try adding it manually.');
  }

  const saved = await AiImport.create({ ...run, status: 'parsed', entries });

  // Same `source` the bulk route would set: receipt/statement for files, text/voice for typed and spoken notes.
  const source = documentType || (isFile ? 'receipt' : inputType);
  try {
    await Transaction.insertMany(entries.map((entry) => ({ ...entry, user: req.user._id, source })));
  } catch (e) {
    saved.status = 'failed';
    saved.error = e.message.slice(0, 200);
    await saved.save();
    throw e;
  }
  saved.status = 'saved';
  saved.savedCount = entries.length;
  await saved.save();

  res.status(201).json({
    success: true,
    message: `${entries.length} ${entries.length === 1 ? 'transaction' : 'transactions'} added`,
    data: null,
  });
});
