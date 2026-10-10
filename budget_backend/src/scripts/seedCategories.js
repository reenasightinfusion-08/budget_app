// Usage: npm run seed:categories
// Upserts the shared category list. Safe to run repeatedly; it never deletes rows.
const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Category = require('../models/Category');
const categories = require('../data/categories');

(async () => {
  await connectDB();
  await Category.syncIndexes();

  const result = await Category.bulkWrite(
    categories.map((c) => ({
      updateOne: {
        filter: { type: c.type, key: c.key },
        update: { $set: c, $setOnInsert: { isActive: true } },
        upsert: true,
      },
    })),
  );

  console.log(`Categories seeded: ${result.upsertedCount} added, ${result.modifiedCount} updated, ${categories.length} total`);
  await mongoose.disconnect();
})().catch((err) => {
  console.error('Seeding failed:', err.message);
  process.exit(1);
});
