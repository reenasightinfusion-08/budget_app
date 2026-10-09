const app = require('../src/app');
const connectDB = require('../src/config/db');

module.exports = async (req, res) => {
  try {
    await connectDB();
  } catch (err) {
    console.error('Database connection failed in serverless handler:', err);
    return res.status(500).json({
      error: 'Database connection failed',
      details: err.message,
    });
  }

  return app(req, res);
};
