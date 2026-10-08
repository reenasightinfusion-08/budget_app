import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';

void main() {
  test('groups digits the Indian way', () {
    expect(AppFormatters.groupDigits(999), '999');
    expect(AppFormatters.groupDigits(15000), '15,000');
    expect(AppFormatters.groupDigits(150000), '1,50,000');
    expect(AppFormatters.groupDigits(1234567), '12,34,567');
  });

  test('formats rupees and parses digits', () {
    expect(AppFormatters.rupees(75000), '₹75,000');
    expect(AppFormatters.parseDigits('₹ 30,000'), 30000);
    expect(AppFormatters.parseDigits(''), 0);
  });
}
