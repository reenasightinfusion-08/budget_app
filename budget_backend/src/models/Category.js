const mongoose = require('mongoose');

// Shared list shown to every user. Transactions and categoryLimits store `key`.
// Categories are switched off (isActive: false), never deleted, so old rows keep a label.
const categorySchema = new mongoose.Schema(
  {
    key: { type: String, required: true, trim: true, lowercase: true },
    type: { type: String, enum: ['income', 'expense'], required: true },
    label: { type: String, required: true, trim: true },
    icon: { type: String, required: true },
    color: { type: String, match: /^#[0-9A-F]{6}$/i },
    // Words the rules parser matches when ai-hub is down, e.g. 'swiggy' -> food.
    keywords: { type: [String], default: [] },
    sortOrder: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true },
);

// 'other' exists for both types, so the key is unique per type.
categorySchema.index({ type: 1, key: 1 }, { unique: true });

module.exports = mongoose.model('Category', categorySchema);
