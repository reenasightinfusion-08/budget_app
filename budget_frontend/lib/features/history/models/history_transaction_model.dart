import 'package:flutter/material.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';

/// Indicates whether a transaction is incoming (income) or outgoing (spend).
enum TransactionType {
  income,
  spend;

  bool get isIncome => this == TransactionType.income;
  bool get isSpend => this == TransactionType.spend;

  String get label => switch (this) {
    TransactionType.income => 'Money in',
    TransactionType.spend => 'Money out',
  };
}

/// Data model representing a transaction entry in history.
class HistoryTransactionModel {
  const HistoryTransactionModel({
    this.id = '',
    required this.date,
    this.createdAt,
    required this.amount,
    required this.type,
    required this.icon,
    required this.bgColor,
    this.iconColor,
    required this.description,
    required this.category,
  });

  final String id;
  final DateTime date;
  final DateTime? createdAt;
  final double amount;
  final TransactionType type;
  final IconData icon;
  final Color bgColor;
  final Color? iconColor;
  final String description;
  final String category;

  /// Helper to check if transaction is income.
  bool get isIncome => type.isIncome;

  /// Helper to check if transaction is spend.
  bool get isSpend => type.isSpend;

  /// Returns the effective icon tint.
  Color get effectiveIconColor =>
      iconColor ?? CategoryRegistry.getColor(category, null, isIncome);

  /// Formatted rupee string, e.g. "₹1,200".
  String get formattedAmount => AppFormatters.rupees(amount.round());

  /// Formatted rupee string with sign, e.g. "+₹5,000" or "-₹250".
  String get signedFormattedAmount =>
      '${isIncome ? '+' : '-'}${AppFormatters.rupees(amount.round())}';

  /// Formatted human-readable date, e.g. "Today" or "Oct 11".
  String get formattedDate {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${AppFormatters.monthShort(date.month)} ${date.day}';
  }

  /// Formats category and date together as shown in UI: "Food · Oct 11".
  String get subtitle => '$category · $formattedDate';

  HistoryTransactionModel copyWith({
    String? id,
    DateTime? date,
    DateTime? createdAt,
    double? amount,
    TransactionType? type,
    IconData? icon,
    Color? bgColor,
    Color? iconColor,
    String? description,
    String? category,
  }) {
    return HistoryTransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      bgColor: bgColor ?? this.bgColor,
      iconColor: iconColor ?? this.iconColor,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  static String categoryKeyToLabel(String key, [String? type]) =>
      CategoryRegistry.getLabel(key, type);

  static IconData categoryKeyToIcon(String key, [String? type]) =>
      CategoryRegistry.getIcon(key, type);

  static Color categoryKeyToColor(String key, [bool isIncome = false]) =>
      CategoryRegistry.getColor(key, isIncome ? 'income' : 'expense', isIncome);

  factory HistoryTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?)?.toLowerCase() ?? 'expense';
    final isIncome = typeStr == 'income';
    final type = isIncome ? TransactionType.income : TransactionType.spend;

    final rawAmount = (json['amount'] as num?)?.toInt() ?? 0;
    // amount in paise -> double amount in rupees
    final double amountRupees = rawAmount / 100.0;

    final catKey = (json['category'] as String?) ?? 'other';
    final label = categoryKeyToLabel(catKey);
    final icon = categoryKeyToIcon(catKey);
    final color = categoryKeyToColor(catKey, isIncome);

    DateTime date;
    try {
      final dateStr = json['date'] as String?;
      date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    } catch (_) {
      date = DateTime.now();
    }

    DateTime? createdAt;
    try {
      final createdStr = json['createdAt'] as String?;
      if (createdStr != null) {
        createdAt = DateTime.parse(createdStr);
      }
    } catch (_) {}

    final note = (json['note'] as String?) ?? '';
    final description = note.isNotEmpty ? note : label;

    return HistoryTransactionModel(
      id: (json['_id'] as String?) ?? '',
      date: date,
      createdAt: createdAt,
      amount: amountRupees,
      type: type,
      icon: icon,
      bgColor: color.withValues(alpha: 0.15),
      iconColor: color,
      description: description,
      category: label,
    );
  }
}
