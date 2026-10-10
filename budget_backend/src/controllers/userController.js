const User = require('../models/User');
const Transaction = require('../models/Transaction');
const AiImport = require('../models/AiImport');
const Goal = require('../models/Goal');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

const publicUser = (user) => {
  const {
    passwordHash, verifyCode, verifyCodeExpires, resetCode, resetCodeExpires,
    lastCodeSentAt, codeAttempts, __v, ...rest
  } = user.toObject({ flattenMaps: true });
  return rest;
};

exports.publicUser = publicUser;

exports.getMe = (req, res) => {
  res.json({ success: true, message: 'OK', data: { user: publicUser(req.user) } });
};

exports.updateMe = asyncHandler(async (req, res) => {
  const { user } = req;
  const { name, photoUrl, monthlyBudget, categoryLimits } = req.body;

  if (name !== undefined) user.name = name;
  if (photoUrl !== undefined) user.photoUrl = photoUrl;
  if (monthlyBudget !== undefined) user.monthlyBudget = monthlyBudget;

  if (categoryLimits !== undefined) {
    if (typeof categoryLimits !== 'object' || categoryLimits === null || Array.isArray(categoryLimits)) {
      throw httpError(400, 'categoryLimits must be an object');
    }
    for (const [key, value] of Object.entries(categoryLimits)) {
      if (!/^[a-z]+$/.test(key)) throw httpError(400, `Invalid category key "${key}"`);
      user.categoryLimits.set(key, value);
    }
  }

  if (user.name && user.monthlyBudget > 0) user.onboardingComplete = true;

  await user.save();
  res.json({ success: true, message: 'Profile updated', data: { user: publicUser(user) } });
});

exports.deleteMe = asyncHandler(async (req, res) => {
  const user = req.user._id;
  await Promise.all([
    Transaction.deleteMany({ user }),
    Goal.deleteMany({ user }),
    AiImport.deleteMany({ user }),
  ]);
  await User.deleteOne({ _id: user });
  res.json({ success: true, message: 'Account deleted', data: null });
});

// Start fresh: keeps the account, name, budget, limits and settings.
exports.clearData = asyncHandler(async (req, res) => {
  const user = req.user._id;
  await Promise.all([Transaction.deleteMany({ user }), Goal.deleteMany({ user })]);
  await User.updateOne({ _id: user }, { $set: { hasExampleData: false } });
  res.json({ success: true, message: 'All data cleared', data: null });
});
