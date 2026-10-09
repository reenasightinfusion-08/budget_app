const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../config');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

module.exports = asyncHandler(async (req, res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) throw httpError(401, 'Missing token');

  let payload;
  try {
    payload = jwt.verify(token, jwtSecret);
  } catch {
    throw httpError(401, 'Invalid or expired token');
  }

  const user = await User.findById(payload.id);
  if (!user) throw httpError(401, 'User no longer exists');
  req.user = user;
  next();
});
