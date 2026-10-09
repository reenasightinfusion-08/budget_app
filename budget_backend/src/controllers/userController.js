const User = require('../models/User');
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
  // transactions, goals and aiimports are removed here once those collections exist
  await User.deleteOne({ _id: req.user._id });
  res.json({ success: true, message: 'Account deleted', data: null });
});
