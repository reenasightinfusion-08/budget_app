const mongoose = require('mongoose');
const Category = require('./Category');
const { isWholeNumber, DAY } = require('../utils/validators');

// Loaded once and refreshed every 5 minutes; there are only a dozen categories.
let known = null;
let loadedAt = 0;
async function isCategory(type, key) {
  if (!known || Date.now() - loadedAt > 5 * 60 * 1000) {
    const rows = await Category.find({ isActive: true }, 'type key').lean();
    known = new Set(rows.map((c) => `${c.type}:${c.key}`));
    loadedAt = Date.now();
  }
  return known.has(`${type}:${key}`);
}

// One spend or one income. Totals, insights and Budgie's mood are all worked out
// from these rows at read time; nothing derived from them is stored.
const transactionSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['income', 'expense'], required: true },
    // Paise, always positive; `type` says which way the money moved. ₹250.50 -> 25050.
    amount: { type: Number, required: true, min: 1, max: 9999999999, validate: isWholeNumber },
    // A category key of the same type, e.g. 'food' for an expense.
    category: {
      type: String,
      required: true,
      trim: true,
      validate: {
        validator(key) {
          return isCategory(this.type, key);
        },
        message: 'Unknown category for this type',
      },
    },
    note: { type: String, default: '', trim: true, maxlength: 40 },
    // The user's local calendar day the money moved, YYYY-MM-DD.
    date: { type: String, required: true, match: DAY },
    // How it was entered. 'manual' = keypad; the others come from Smart add.
    source: {
      type: String,
      enum: ['manual', 'text', 'voice', 'receipt', 'statement'],
      default: 'manual',
    },
  },
  { timestamps: true },
);

// Serves every screen: month totals, week bars, pace chart, Recent and History (newest first).
transactionSchema.index({ user: 1, date: -1, createdAt: -1 });

module.exports = mongoose.model('Transaction', transactionSchema);
