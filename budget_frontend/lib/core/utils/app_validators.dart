import 'package:flutter/material.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';

class AppValidators {
  static final RegExp emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp codePattern = RegExp(r'^\d{6}$');
  static const int minPasswordLength = 6;

  static String? email(String? value) =>
      emailPattern.hasMatch((value ?? '').trim()) ? null : 'Enter a valid email address.';

  static String? loginPassword(String? value) =>
      (value ?? '').isEmpty ? 'Enter your password.' : null;

  static String? newPassword(String? value) => (value ?? '').length < minPasswordLength
      ? 'Use at least $minPasswordLength characters for your password.'
      : null;

  static String? name(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter your first name.' : null;

  static String? budget(String? value) =>
      AppFormatters.parseDigits(value ?? '') > 0 ? null : 'Enter a monthly budget above 0.';

  static String? code(String? value) =>
      codePattern.hasMatch((value ?? '').trim()) ? null : 'Enter the 6-digit code.';

  static FormFieldValidator<String> confirmPassword(TextEditingController original) =>
      (value) => value == original.text ? null : 'The two passwords don’t match.';
}
