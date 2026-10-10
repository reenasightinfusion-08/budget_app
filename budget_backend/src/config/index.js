require('dotenv').config();

const env = process.env.NODE_ENV || 'development';

module.exports = {
  port: process.env.PORT || 3000,
  env,
  jwtSecret: process.env.JWT_SECRET,
  aiHubUrl: (process.env.AI_HUB_URL || '').replace(/\/$/, ''),
  aiHubSecret: process.env.AI_HUB_SECRET,
  smartAddDailyLimit: Number(process.env.SMART_ADD_DAILY_LIMIT) || 30,
  mongoUri:
    process.env.MONGODB_URI ||
    process.env.MONGODB_URI_ATLAS ||
    process.env.MONGODB_URI_LOCAL,
};
