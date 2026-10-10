const mongoose = require('mongoose');
const { isWholeNumber, DAY } = require('../utils/validators');

// One entry the AI suggested, as shown on the review screen.
const suggestedEntrySchema = new mongoose.Schema(
  {
    type: { type: String, enum: ['income', 'expense'], required: true },
    amount: { type: Number, required: true, min: 1, validate: isWholeNumber },
    category: { type: String, required: true },
    note: { type: String, default: '', maxlength: 40 },
    date: { type: String, required: true, match: DAY },
  },
  { _id: false },
);

// One Smart add run (typed text, voice, bill photo or PDF) sent through ai-hub.
// A working log for the daily limit and for checking AI quality, not history,
// so MongoDB deletes each one 90 days after it was made.
const aiImportSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    inputType: { type: String, enum: ['text', 'voice', 'image', 'pdf'], required: true },
    // What the AI found in a photo or PDF. Null for typed or spoken text.
    documentType: { type: String, enum: ['receipt', 'statement'], default: null },
    // Kept only for typed or spoken text. Bill and bank-statement text is never stored.
    inputText: { type: String, default: null, maxlength: 500 },
    // 'ai' = read by ai-hub, 'rules' = keyword parser used when ai-hub failed.
    parser: { type: String, enum: ['ai', 'rules'], required: true },
    // Provider ai-hub routed to ('groq', 'gemini', ...). Null when parser is 'rules'.
    provider: { type: String, default: null },
    status: { type: String, enum: ['parsed', 'saved', 'failed'], default: 'parsed' },
    entries: { type: [suggestedEntrySchema], default: [] },
    // How many entries the user kept when they tapped "Add".
    savedCount: { type: Number, default: 0, min: 0 },
    error: { type: String, default: null },
  },
  { timestamps: true },
);

// Serves the daily Smart add limit (count today's runs) and the user's recent runs.
aiImportSchema.index({ user: 1, createdAt: -1 });
// Auto-delete after 90 days.
aiImportSchema.index({ createdAt: 1 }, { expireAfterSeconds: 90 * 24 * 60 * 60 });

module.exports = mongoose.model('AiImport', aiImportSchema);
