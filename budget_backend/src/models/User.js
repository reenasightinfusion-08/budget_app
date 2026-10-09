const mongoose = require('mongoose');
const { isWholeNumber } = require('../utils/validators');

const userSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, default: null },
    googleId: { type: String, unique: true, sparse: true },
    isVerified: { type: Boolean, default: false },
    verifyCode: { type: String, default: null },
    verifyCodeExpires: { type: Date, default: null },
    resetCode: { type: String, default: null },
    resetCodeExpires: { type: Date, default: null },
    lastCodeSentAt: { type: Date, default: null },
    codeAttempts: { type: Number, default: 0, min: 0 },

    name: { type: String, default: '', trim: true, maxlength: 24 },
    photoUrl: { type: String, default: null },
    onboardingComplete: { type: Boolean, default: false },

    monthlyBudget: { type: Number, default: 0, min: 0, validate: isWholeNumber },
    categoryLimits: {
      type: Map,
      of: { type: Number, min: 0, validate: isWholeNumber },
      default: {},
    },

    hasExampleData: { type: Boolean, default: false },
  },
  { timestamps: true },
);

module.exports = mongoose.model('User', userSchema);
