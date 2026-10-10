const Goal = require('../models/Goal');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');
const dates = require('../utils/dates');

const MAX_GOALS = 50;

const publicGoal = (g) => ({
  _id: g._id,
  name: g.name,
  icon: g.icon,
  targetAmount: g.targetAmount,
  targetMonth: g.targetMonth,
  savedAmount: g.savedAmount,
  reachedAt: g.reachedAt,
  contributions: g.contributions.map((c) => ({ amount: c.amount, date: c.date })),
  createdAt: g.createdAt,
});

exports.list = asyncHandler(async (req, res) => {
  const { month } = req.query;
  if (month !== undefined && !dates.isMonth(month)) throw httpError(400, 'month must be YYYY-MM');

  const goals = await Goal.find({ user: req.user._id }).sort({ createdAt: 1 });

  // Net money put aside in the month (Take out counts as negative), across all goals.
  const from = dates.monthStart(month || dates.latestAllowedDay().slice(0, 7));
  const to = dates.monthStart(dates.addMonths(from.slice(0, 7), 1));
  const thisMonth = goals
    .flatMap((g) => g.contributions)
    .filter((c) => c.date >= from && c.date < to)
    .reduce((sum, c) => sum + c.amount, 0);

  res.json({
    success: true,
    message: 'OK',
    data: { goals: goals.map(publicGoal), totalSaved: goals.reduce((sum, g) => sum + g.savedAmount, 0), thisMonth },
  });
});

exports.create = asyncHandler(async (req, res) => {
  const { name, icon, targetAmount, targetMonth } = req.body || {};

  if (typeof name !== 'string' || !name.trim()) throw httpError(400, 'name is required');
  if (name.trim().length > 28) throw httpError(400, 'name can be at most 28 characters');
  if (!Number.isInteger(targetAmount) || targetAmount < 100) {
    throw httpError(400, 'targetAmount must be a whole number of paise, at least 100');
  }
  if (!dates.isMonth(targetMonth)) throw httpError(400, 'targetMonth must be YYYY-MM');
  if (await Goal.countDocuments({ user: req.user._id }) >= MAX_GOALS) {
    throw httpError(400, `At most ${MAX_GOALS} goals`);
  }

  await Goal.create({
    user: req.user._id,
    name,
    targetAmount,
    targetMonth,
    ...(icon !== undefined && { icon }),
  }).catch((e) => {
    if (e.code === 11000) throw httpError(409, 'You already have a goal with this name');
    throw e;
  });

  res.status(201).json({ success: true, message: 'Goal created', data: null });
});

exports.addContribution = asyncHandler(async (req, res) => {
  const { amount, date, today } = req.body || {};

  if (!Number.isInteger(amount) || amount === 0) throw httpError(400, 'amount must be a whole number of paise, not 0');
  if (!dates.isDay(date)) throw httpError(400, 'date must be YYYY-MM-DD');
  if (date > dates.latestAllowedDay(today)) throw httpError(400, 'date cannot be in the future');

  // Load and save (not $push) so the pre('validate') hook recalculates savedAmount and reachedAt.
  const goal = await Goal.findOne({ _id: req.params.id, user: req.user._id });
  if (!goal) throw httpError(404, 'Goal not found');

  goal.contributions.push({ amount, date });
  await goal.save();

  res.status(201).json({ success: true, message: amount > 0 ? 'Money added' : 'Money taken out', data: null });
});

exports.remove = asyncHandler(async (req, res) => {
  const result = await Goal.deleteOne({ _id: req.params.id, user: req.user._id });
  if (result.deletedCount === 0) throw httpError(404, 'Goal not found');
  res.json({ success: true, message: 'Goal deleted', data: null });
});
