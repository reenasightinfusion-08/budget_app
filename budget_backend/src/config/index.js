require('dotenv').config();

const env = process.env.NODE_ENV || 'development';

module.exports = {
  port: process.env.PORT || 3000,
  env,
  jwtSecret: process.env.JWT_SECRET,
  mongoUri:
    process.env.MONGODB_URI ||
    process.env.MONGODB_URI_ATLAS ||
    process.env.MONGODB_URI_LOCAL,
};
