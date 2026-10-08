import 'package:flutter/services.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';

class IndianDigitsFormatter extends TextInputFormatter {
  const IndianDigitsFormatter();

  static const int maxDigits = 7;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final capped = digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;
    final text = AppFormatters.groupDigits(int.parse(capped));
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
