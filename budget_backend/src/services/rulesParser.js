const dates = require('../utils/dates');

const INCOME_WORDS = /\b(salary|received|credited|credit|income|refund|bonus|cashback|stipend|earned|got paid)\b/i;
const AMOUNT = /(?:₹|rs\.?|inr)?\s*(\d[\d,]*(?:\.\d+)?)\s*(k\b)?/i;

// Keyword fallback for when ai-hub is down: "lunch 250 and fuel 500 yesterday".
// `categories` is [{ type, key, keywords }]. Returns entries with amounts in rupees.
module.exports = function parseWithRules(text, today, categories) {
  const sharedDay = /day before yesterday/i.test(text)
    ? dates.addDays(today, -2)
    : /yesterday/i.test(text) ? dates.addDays(today, -1) : today;

  const entries = [];
  for (const segment of text.split(/\band\b|(?<!\d),|,(?!\d)|[;\n]+/i)) {
    const match = segment.match(AMOUNT);
    if (!match) continue;

    const amount = Number(match[1].replace(/,/g, '')) * (match[2] ? 1000 : 1);
    if (!(amount > 0)) continue;

    const words = segment.toLowerCase();
    const type = INCOME_WORDS.test(segment) ? 'income' : 'expense';
    const hit = categories.find(
      (c) => c.type === type && c.keywords.some((k) => new RegExp(`\\b${k}\\b`).test(words)),
    );

    const note = segment
      .replace(AMOUNT, ' ')
      .replace(/\b(today|yesterday|day before yesterday|rupees|rs|for|on|paid|spent|bought)\b/gi, ' ')
      .replace(/[₹]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();

    entries.push({
      type,
      amount,
      category: hit ? hit.key : 'other',
      note: note.charAt(0).toUpperCase() + note.slice(1),
      date: sharedDay,
    });
  }
  return entries;
};
