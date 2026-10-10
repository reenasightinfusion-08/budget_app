const Category = require('../models/Category');
const asyncHandler = require('../utils/asyncHandler');

// Keywords are for the server-side rules parser, so the app never receives them.
exports.list = asyncHandler(async (req, res) => {
  const categories = await Category.find({ isActive: true })
    .select('key type label icon color sortOrder -_id')
    .sort({ type: 1, sortOrder: 1 })
    .lean();

  res.json({ success: true, message: 'OK', data: { categories } });
});
