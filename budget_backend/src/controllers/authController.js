const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');
const {
  CODE_TTL_MS, RESEND_COOLDOWN_MS, MAX_ATTEMPTS,
  newCode, signToken, hashPassword, checkPassword, deliverCode,
} = require('../services/codes');
const { publicUser } = require('./userController');

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const readEmail = (body) => {
  const email = String(body.email || '').trim().toLowerCase();
  if (!EMAIL.test(email)) throw httpError(400, 'Valid email is required');
  return email;
};

const readPassword = (value, label = 'Password') => {
  const password = String(value || '');
  if (password.length < 8) throw httpError(400, `${label} must be at least 8 characters`);
  return password;
};

const cooldownLeft = (user) =>
  user.lastCodeSentAt ? RESEND_COOLDOWN_MS - (Date.now() - user.lastCodeSentAt.getTime()) : 0;

const issueVerifyCode = async (user) => {
  const code = newCode();
  user.verifyCode = code;
  user.verifyCodeExpires = new Date(Date.now() + CODE_TTL_MS);
  user.lastCodeSentAt = new Date();
  user.codeAttempts = 0;
  await user.save();
  return deliverCode(user.email, 'verify', code);
};

// Compares a submitted code; counts wrong tries and kills the code at MAX_ATTEMPTS.
const checkCode = async (user, field, expiresField, submitted) => {
  const stored = user[field];
  const expires = user[expiresField];
  if (!stored || !expires || expires < new Date()) throw httpError(400, 'Code expired. Request a new one');
  if (user.codeAttempts >= MAX_ATTEMPTS) throw httpError(429, 'Too many wrong codes. Request a new one');
  if (String(submitted || '').trim() !== stored) {
    user.codeAttempts += 1;
    await user.save();
    throw httpError(400, 'Incorrect code');
  }
};

exports.signup = asyncHandler(async (req, res) => {
  const email = readEmail(req.body);
  const password = readPassword(req.body.password);

  let user = await User.findOne({ email });
  if (user && user.isVerified) throw httpError(409, 'Email already registered');
  if (!user) user = new User({ email });
  if (cooldownLeft(user) > 0) throw httpError(429, 'Wait 30 seconds before requesting another code');

  user.passwordHash = await hashPassword(password);
  const devCode = await issueVerifyCode(user);
  res.status(201).json({ success: true, message: 'Verification code sent', data: { email, devCode } });
});

exports.verifyEmail = asyncHandler(async (req, res) => {
  const user = await User.findOne({ email: readEmail(req.body) });
  if (!user) throw httpError(404, 'Account not found');
  if (user.isVerified) throw httpError(400, 'Email already verified');

  await checkCode(user, 'verifyCode', 'verifyCodeExpires', req.body.code);
  user.isVerified = true;
  user.verifyCode = null;
  user.verifyCodeExpires = null;
  user.codeAttempts = 0;
  await user.save();
  res.json({ success: true, message: 'Email verified', data: { token: signToken(user), user: publicUser(user) } });
});

exports.resendCode = asyncHandler(async (req, res) => {
  const user = await User.findOne({ email: readEmail(req.body) });
  if (!user || user.isVerified) throw httpError(404, 'No pending verification for this email');
  if (cooldownLeft(user) > 0) throw httpError(429, 'Wait 30 seconds before requesting another code');

  const devCode = await issueVerifyCode(user);
  res.json({ success: true, message: 'Verification code sent', data: { devCode } });
});

exports.login = asyncHandler(async (req, res) => {
  const user = await User.findOne({ email: readEmail(req.body) });
  if (!user || !(await checkPassword(String(req.body.password || ''), user.passwordHash))) {
    throw httpError(401, 'Invalid email or password');
  }
  if (!user.isVerified) throw httpError(403, 'Email not verified');
  res.json({ success: true, message: 'Logged in', data: { token: signToken(user), user: publicUser(user) } });
});

exports.forgotPassword = asyncHandler(async (req, res) => {
  const email = readEmail(req.body);
  const user = await User.findOne({ email });
  let devCode;

  if (user && user.isVerified && cooldownLeft(user) <= 0) {
    const code = newCode();
    user.resetCode = code;
    user.resetCodeExpires = new Date(Date.now() + CODE_TTL_MS);
    user.lastCodeSentAt = new Date();
    user.codeAttempts = 0;
    await user.save();
    devCode = deliverCode(email, 'reset', code);
  }
  res.json({ success: true, message: 'If the email is registered, a reset code was sent', data: { devCode } });
});

exports.verifyResetCode = asyncHandler(async (req, res) => {
  const user = await User.findOne({ email: readEmail(req.body) });
  if (!user) throw httpError(400, 'Incorrect code');
  await checkCode(user, 'resetCode', 'resetCodeExpires', req.body.code);
  res.json({ success: true, message: 'Code is valid', data: null });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const newPassword = readPassword(req.body.newPassword, 'New password');
  const user = await User.findOne({ email: readEmail(req.body) });
  if (!user) throw httpError(400, 'Incorrect code');

  await checkCode(user, 'resetCode', 'resetCodeExpires', req.body.code);
  user.passwordHash = await hashPassword(newPassword);
  user.resetCode = null;
  user.resetCodeExpires = null;
  user.codeAttempts = 0;
  await user.save();
  res.json({ success: true, message: 'Password updated', data: null });
});

exports.changePassword = asyncHandler(async (req, res) => {
  const newPassword = readPassword(req.body.newPassword, 'New password');
  const { user } = req;
  if (user.passwordHash && !(await checkPassword(String(req.body.currentPassword || ''), user.passwordHash))) {
    throw httpError(401, 'Current password is incorrect');
  }
  user.passwordHash = await hashPassword(newPassword);
  await user.save();
  res.json({ success: true, message: 'Password changed', data: null });
});
