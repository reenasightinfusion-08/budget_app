const app = require('./app');
const connectDB = require('./config/db');
const { port } = require('./config');

connectDB()
  .then(() => app.listen(port, () => console.log(`budget_backend running on port ${port}`)))
  .catch((err) => {
    console.error('MongoDB connection failed:', err.message);
    process.exit(1);
  });
