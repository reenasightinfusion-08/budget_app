const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { jwtSecret, env } = require('../config');

const CODE_TTL_MS = 15 * 60 * 1000;
const RESEND_COOLDOWN_MS = 30 * 1000;
const MAX_ATTEMPTS = 5;

const newCode = () => String(crypto.randomInt(0, 1000000)).padStart(6, '0');
const signToken = (user) => jwt.sign({ id: user._id }, jwtSecret, { expiresIn: '30d' });
const hashPassword = (password) => bcrypt.hash(password, 12);
const checkPassword = (password, hash) => (hash ? bcrypt.compare(password, hash) : false);

// No mail provider yet: outside production (or with EXPOSE_DEV_CODE=true) the code is
// returned in the response so it can be used without an email.
const deliverCode = (email, kind, code) => {
  if (env === 'production' && process.env.EXPOSE_DEV_CODE !== 'true') return undefined;
  console.log(`[${kind}] ${email} -> ${code}`);
  return code;
};

module.exports = {
  CODE_TTL_MS,
  RESEND_COOLDOWN_MS,
  MAX_ATTEMPTS,
  newCode,
  signToken,
  hashPassword,
  checkPassword,
  deliverCode,
};
