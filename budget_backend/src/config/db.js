const dns = require('dns');
const mongoose = require('mongoose');
const { mongoUri } = require('./index');

dns.setServers(['8.8.8.8', '1.1.1.1']);

module.exports = async () => {
  await mongoose.connect(mongoUri);
  console.log('MongoDB connected');
};
