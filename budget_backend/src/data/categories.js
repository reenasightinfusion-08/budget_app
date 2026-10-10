// Seed list for the categories collection (see scripts/seedCategories.js).
const expense = (sortOrder, key, label, color, keywords = [], icon = key) => ({
  type: 'expense', sortOrder, key, label, icon, color, keywords,
});
const income = (sortOrder, key, label, color, keywords = [], icon = key) => ({
  type: 'income', sortOrder, key, label, icon, color, keywords,
});

module.exports = [
  expense(1, 'food', 'Food', '#E8913A', [
    'lunch', 'dinner', 'breakfast', 'brunch', 'coffee', 'tea', 'chai', 'snack', 'grocery', 'groceries',
    'restaurant', 'cafe', 'swiggy', 'zomato', 'dmart', 'bigbasket', 'blinkit', 'zepto', 'pizza', 'burger',
    'biryani', 'meal', 'food', 'juice', 'bakery', 'vegetables', 'fruits', 'milk', 'dominos', 'kfc',
  ]),
  expense(2, 'bills', 'Bills', '#5B6CE0', [
    'bill', 'electricity', 'internet', 'wifi', 'broadband', 'recharge', 'mobile', 'phone bill', 'water',
    'gas', 'lpg', 'dth', 'insurance', 'emi', 'loan', 'rent', 'subscription', 'netflix', 'spotify',
    'prime', 'maintenance', 'tax', 'airtel', 'jio',
  ]),
  expense(3, 'travel', 'Travel', '#2C9CB8', [
    'uber', 'ola', 'cab', 'taxi', 'auto', 'rickshaw', 'bus', 'train', 'metro', 'flight', 'ticket',
    'petrol', 'diesel', 'fuel', 'toll', 'parking', 'irctc', 'redbus', 'rapido', 'hotel', 'trip',
  ]),
  expense(4, 'shopping', 'Shopping', '#D9645A', [
    'amazon', 'flipkart', 'myntra', 'clothes', 'shirt', 'shoes', 'sneakers', 'jeans', 'dress', 'watch',
    'bag', 'electronics', 'gadget', 'headphones', 'meesho', 'ajio', 'nykaa', 'mall', 'shopping',
  ]),
  expense(5, 'home', 'Home', '#8E63D2', [
    'rent', 'furniture', 'repair', 'plumber', 'electrician', 'cleaning', 'maid', 'paint', 'ikea',
    'appliance', 'kitchen', 'decor', 'mattress', 'curtain', 'household', 'laundry',
  ], 'house'),
  expense(6, 'health', 'Health', '#2E9A6E', [
    'doctor', 'medicine', 'pharmacy', 'hospital', 'clinic', 'medical', 'dentist', 'lab', 'test',
    'checkup', 'gym', 'yoga', 'vitamins', 'apollo', 'medplus', 'therapy', 'eye',
  ]),
  expense(7, 'fun', 'Fun', '#D2599B', [
    'movie', 'cinema', 'game', 'concert', 'party', 'pub', 'bar', 'club', 'outing', 'netflix',
    'bookmyshow', 'gaming', 'bowling', 'park', 'event', 'drinks', 'beer',
  ]),
  expense(8, 'other', 'Other', '#868C96'),

  income(1, 'salary', 'Salary', '#2E9A6E', ['salary', 'payroll', 'wages', 'stipend']),
  income(2, 'freelance', 'Side work', '#5B6CE0', [
    'freelance', 'client', 'project', 'invoice', 'consult', 'gig', 'side hustle', 'contract',
  ]),
  income(3, 'gift', 'Gift', '#D2599B', [
    'gift', 'birthday', 'present', 'diwali', 'bonus', 'cashback', 'reward', 'refund',
  ]),
  income(4, 'other', 'Other', '#868C96'),
];
