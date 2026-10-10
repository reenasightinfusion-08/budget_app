const Transaction = require('../models/Transaction');
const Category = require('../models/Category');
const AiImport = require('../models/AiImport');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');
const dates = require('../utils/dates');

const MAX_BULK = 80;
const DEFAULT_PAGE = 50;
const MAX_PAGE = 100;

const publicTransaction = (t) => ({
  _id: t._id,
  type: t.type,
  amount: t.amount,
  category: t.category,
  note: t.note,
  date: t.date,
  source: t.source,
  createdAt: t.createdAt,
});

const { latestAllowedDay } = dates;

const readEntry = (raw, latestDay) => {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw httpError(400, 'Each entry must be an object');
  const { type, amount, category, note, date } = raw;

  if (type !== 'income' && type !== 'expense') throw httpError(400, 'type must be income or expense');
  if (!Number.isInteger(amount) || amount < 1) throw httpError(400, 'amount must be a whole number of paise above 0');
  if (typeof category !== 'string' || !category.trim()) throw httpError(400, 'category is required');
  if (note !== undefined && note !== null && typeof note !== 'string') throw httpError(400, 'note must be text');
  if (note && note.trim().length > 40) throw httpError(400, 'note can be at most 40 characters');
  if (!dates.isDay(date)) throw httpError(400, 'date must be YYYY-MM-DD');
  if (date > latestDay) throw httpError(400, 'date cannot be in the future');

  return { type, amount, category: category.trim().toLowerCase(), note: note || '', date };
};

exports.create = asyncHandler(async (req, res) => {
  const entry = readEntry(req.body, latestAllowedDay(req.body && req.body.today));
  await Transaction.create({ ...entry, user: req.user._id, source: 'manual' });
  res.status(201).json({ success: true, message: 'Transaction added', data: null });
});

exports.bulk = asyncHandler(async (req, res) => {
  const { importId, entries, today } = req.body || {};

  if (!Array.isArray(entries) || entries.length === 0) throw httpError(400, 'entries must be a non-empty list');
  if (entries.length > MAX_BULK) throw httpError(400, `At most ${MAX_BULK} entries at a time`);
  const latestDay = latestAllowedDay(today);
  const clean = entries.map((entry) => readEntry(entry, latestDay));

  let run = null;
  if (importId !== undefined && importId !== null) {
    run = await AiImport.findOne({ _id: importId, user: req.user._id });
    if (!run) throw httpError(404, 'Smart add run not found');
    if (run.status === 'saved') throw httpError(409, 'This Smart add run was already saved');
  }

  let source = 'manual';
  if (run) source = run.documentType || (['text', 'voice'].includes(run.inputType) ? run.inputType : 'receipt');

  // Mongoose validates every row before inserting any, so a bad entry saves nothing.
  await Transaction.insertMany(clean.map((entry) => ({ ...entry, user: req.user._id, source })));

  if (run) {
    run.status = 'saved';
    run.savedCount = clean.length;
    await run.save();
  }

  res.status(201).json({ success: true, message: `${clean.length} transactions added`, data: null });
});

exports.remove = asyncHandler(async (req, res) => {
  const result = await Transaction.deleteOne({ _id: req.params.id, user: req.user._id });
  if (result.deletedCount === 0) throw httpError(404, 'Transaction not found');
  res.json({ success: true, message: 'Transaction deleted', data: null });
});

const escapeRegex = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

exports.list = asyncHandler(async (req, res) => {
  const { type, q, before } = req.query;
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || DEFAULT_PAGE, 1), MAX_PAGE);

  if (type !== undefined && type !== 'income' && type !== 'expense') throw httpError(400, 'type must be income or expense');
  if (before !== undefined && !dates.isDay(before)) throw httpError(400, 'before must be YYYY-MM-DD');

  const filter = { user: req.user._id };
  if (type) filter.type = type;
  if (before) filter.date = { $lt: before };

  const search = typeof q === 'string' ? q.trim() : '';
  if (search) {
    const pattern = new RegExp(escapeRegex(search), 'i');
    // A category label like "Side work" also matches entries stored under its key.
    const keys = await Category.find({ label: pattern, ...(type && { type }) }).distinct('key');
    filter.$or = [{ note: pattern }, { category: { $in: keys } }];
  }

  const sort = { date: -1, createdAt: -1 };
  let rows = await Transaction.find(filter).sort(sort).limit(limit + 1).lean();
  let nextBefore = null;

  if (rows.length > limit) {
    // Cut at a day boundary so a day is never split across two pages.
    const overflowDay = rows[limit].date;
    const whole = rows.filter((row) => row.date > overflowDay);

    if (whole.length > 0) {
      rows = whole;
    } else {
      // One day holds more than a page: return all of it.
      rows = await Transaction.find({ ...filter, date: overflowDay }).sort(sort).lean();
    }
    nextBefore = rows[rows.length - 1].date;
  }

  res.json({
    success: true,
    message: 'OK',
    data: { transactions: rows.map(publicTransaction), nextBefore },
  });
});

const sumByDate = (user, from, to, type) =>
  Transaction.aggregate([
    { $match: { user, type, date: { $gte: from, $lte: to } } },
    { $group: { _id: '$date', total: { $sum: '$amount' } } },
    { $sort: { _id: 1 } },
  ]);

exports.summary = asyncHandler(async (req, res) => {
  const { month, today } = req.query;
  if (!dates.isMonth(month)) throw httpError(400, 'month must be YYYY-MM');
  if (!dates.isDay(today)) throw httpError(400, 'today must be YYYY-MM-DD');

  const user = req.user._id;
  const monthFrom = dates.monthStart(month);
  const monthTo = `${month}-${String(dates.daysInMonth(month)).padStart(2, '0')}`;

  // Same days of last month as have passed this month, for "7% less than Sep".
  const previous = dates.addMonths(month, -1);
  const sameDay = today.startsWith(month) ? Number(today.slice(8)) : dates.daysInMonth(previous);
  const previousTo = `${previous}-${String(Math.min(sameDay, dates.daysInMonth(previous))).padStart(2, '0')}`;

  // Daily spending covers the month and the week holding `today`, which can start last month.
  const weekFrom = dates.weekStart(today);
  const weekTo = dates.addDays(weekFrom, 6);
  const dailyFrom = weekFrom < monthFrom ? weekFrom : monthFrom;
  const dailyTo = weekTo > monthTo ? weekTo : monthTo;

  const sixFrom = dates.monthStart(dates.addMonths(month, -5));

  const [byCategory, daily, previousSpent, sixMonths, recent, entries, activeMonths] = await Promise.all([
    Transaction.aggregate([
      { $match: { user, date: { $gte: monthFrom, $lte: monthTo } } },
      { $group: { _id: { type: '$type', category: '$category' }, total: { $sum: '$amount' } } },
    ]),
    sumByDate(user, dailyFrom, dailyTo, 'expense'),
    Transaction.aggregate([
      { $match: { user, type: 'expense', date: { $gte: dates.monthStart(previous), $lte: previousTo } } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]),
    Transaction.aggregate([
      { $match: { user, date: { $gte: sixFrom, $lte: monthTo } } },
      { $group: { _id: { month: { $substrBytes: ['$date', 0, 7] }, type: '$type' }, total: { $sum: '$amount' } } },
    ]),
    Transaction.find({ user }).sort({ date: -1, createdAt: -1 }).limit(4).lean(),
    Transaction.countDocuments({ user }),
    Transaction.aggregate([
      { $match: { user } },
      { $group: { _id: { $substrBytes: ['$date', 0, 7] } } },
      { $count: 'months' },
    ]),
  ]);

  const categories = byCategory.map((row) => ({ type: row._id.type, category: row._id.category, total: row.total }));
  const totalOf = (type) => categories.filter((c) => c.type === type).reduce((sum, c) => sum + c.total, 0);

  const months = Array.from({ length: 6 }, (_, i) => {
    const key = dates.addMonths(month, i - 5);
    const total = (type) => (sixMonths.find((r) => r._id.month === key && r._id.type === type) || {}).total || 0;
    return { month: key, income: total('income'), expense: total('expense') };
  });

  res.json({
    success: true,
    message: 'OK',
    data: {
      month,
      today,
      income: totalOf('income'),
      expense: totalOf('expense'),
      byCategory: categories,
      weekStart: weekFrom,
      daily: daily.map((row) => ({ date: row._id, spent: row.total })),
      previousMonthSoFar: previousSpent.length ? previousSpent[0].total : 0,
      months,
      recent: recent.map(publicTransaction),
      counts: { entries, months: activeMonths.length ? activeMonths[0].months : 0 },
    },
  });
});
