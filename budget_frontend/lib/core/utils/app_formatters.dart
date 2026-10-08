class AppFormatters {
  /// Groups digits the Indian way (12,34,567) because budgets are entered in rupees.
  static String groupDigits(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final groupedHead = head.replaceAllMapped(RegExp(r'\B(?=(\d{2})+(?!\d))'), (_) => ',');
    return '$groupedHead,$tail';
  }

  static String rupees(int value) => '₹${groupDigits(value)}';

  static int parseDigits(String text) => int.tryParse(text.replaceAll(RegExp(r'\D'), '')) ?? 0;
}
