const dns = require('dns');
const mongoose = require('mongoose');
const { mongoUri } = require('./index');

if (mongoUri && mongoUri.startsWith('mongodb+srv://')) {
  try {
    dns.setServers(['8.8.8.8', '1.1.1.1']);
  } catch {
    // Ignore in environments where custom DNS servers cannot be set
  }
}

let cachedConnection = null;

module.exports = async () => {
  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  if (!cachedConnection) {
    if (!mongoUri) {
      throw new Error('MongoDB connection URI is missing. Set MONGODB_URI or MONGODB_URI_ATLAS.');
    }
    cachedConnection = mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000,
    });
  }

  try {
    await cachedConnection;
    console.log('MongoDB connected');
    return mongoose.connection;
  } catch (err) {
    cachedConnection = null;
    throw err;
  }
};
