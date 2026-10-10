const { DAY, MONTH } = require('./validators');

// Days are "YYYY-MM-DD" strings in the user's own calendar. All maths below runs in UTC
// on those strings so the server's time zone never shifts a day.
const pad = (n) => String(n).padStart(2, '0');
const toDay = (d) => `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
const parseDay = (s) => {
  const [y, m, d] = s.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
};

const isDay = (s) => typeof s === 'string' && DAY.test(s) && toDay(parseDay(s)) === s;
const isMonth = (s) => typeof s === 'string' && MONTH.test(s);

const addDays = (s, n) => {
  const d = parseDay(s);
  d.setUTCDate(d.getUTCDate() + n);
  return toDay(d);
};

const addMonths = (month, n) => {
  const [y, m] = month.split('-').map(Number);
  const d = new Date(Date.UTC(y, m - 1 + n, 1));
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}`;
};

const monthStart = (month) => `${month}-01`;
const daysInMonth = (month) => {
  const [y, m] = month.split('-').map(Number);
  return new Date(Date.UTC(y, m, 0)).getUTCDate();
};

// Monday of the week that holds `day`.
const weekStart = (day) => addDays(day, -((parseDay(day).getUTCDay() + 6) % 7));

// The furthest-ahead calendar day anywhere on Earth right now (UTC+14). Used as the
// "not in the future" limit when the app does not say what its today is.
const latestPossibleDay = () => toDay(new Date(Date.now() + 14 * 60 * 60 * 1000));

module.exports = {
  isDay, isMonth, addDays, addMonths, monthStart, daysInMonth, weekStart, latestPossibleDay,
};
