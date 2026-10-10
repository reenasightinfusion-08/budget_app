const mongoose = require('mongoose');
const { isWholeNumber, DAY, MONTH } = require('../utils/validators');

// One "Add money" or "Take out" on a goal.
const contributionSchema = new mongoose.Schema(
  {
    // Paise. Positive = put aside, negative = taken out.
    amount: {
      type: Number,
      required: true,
      validate: [isWholeNumber, { validator: (v) => v !== 0, message: 'Amount cannot be 0' }],
    },
    date: { type: String, required: true, match: DAY },
  },
  { _id: false },
);

// A savings goal. Its money log is embedded: a goal gets a few entries a month
// and is always read whole.
const goalSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true, trim: true, maxlength: 28 },
    icon: { type: String, enum: ['shield', 'phone', 'plane', 'house', 'gift', 'star'], default: 'star' },
    targetAmount: { type: Number, required: true, min: 100, validate: isWholeNumber },
    // The month the user wants to reach it by, YYYY-MM.
    targetMonth: { type: String, required: true, match: MONTH },
    // Oldest first.
    contributions: { type: [contributionSchema], default: [] },

    // Derived from contributions, never trusted from the client - see pre('validate').
    // min: 0 is what stops "Take out" from going below what was saved.
    savedAmount: { type: Number, default: 0, min: [0, 'Cannot take out more than is saved'] },
    reachedAt: { type: Date, default: null },
  },
  { timestamps: true },
);

// A name only has to be unique within one user's goals; this also stops a double-tapped Create.
goalSchema.index({ user: 1, name: 1 }, { unique: true });

goalSchema.pre('validate', function () {
  this.savedAmount = this.contributions.reduce((sum, c) => sum + c.amount, 0);
  if (this.savedAmount < this.targetAmount) this.reachedAt = null;
  else if (!this.reachedAt) this.reachedAt = new Date();
});

module.exports = mongoose.model('Goal', goalSchema);
