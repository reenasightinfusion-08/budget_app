import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

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
      iconColor ??
      switch (category) {
        'Food' => AppColors.catFood,
        'Fun' => AppColors.catFun,
        'Shopping' => AppColors.catShopping,
        'Bills' => AppColors.catBills,
        'Travel' => AppColors.catTravel,
        'Health' => AppColors.catHealth,
        'Salary' => AppColors.success,
        'Side Work' => AppColors.catBills,
        'Gift' => AppColors.catFun,
        _ => (isIncome ? AppColors.success : AppColors.ink),
      };

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
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      bgColor: bgColor ?? this.bgColor,
      iconColor: iconColor ?? this.iconColor,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  /// Dummy transactions matching design screenshot and supporting all filter modes.
  static List<HistoryTransactionModel> get dummyData => [
        HistoryTransactionModel(
          id: 'tx_1',
          date: DateTime(2026, 10, 13), // Today
          amount: 799,
          type: TransactionType.spend,
          icon: AppIcons.catBills,
          bgColor: const Color(0xFFECEFFC),
          iconColor: AppColors.catBills,
          description: 'WiFi & Internet',
          category: 'Bills',
        ),
        HistoryTransactionModel(
          id: 'tx_2',
          date: DateTime(2026, 10, 11),
          amount: 1600,
          type: TransactionType.spend,
          icon: AppIcons.catFood,
          bgColor: const Color(0xFFFFF1E5),
          iconColor: AppColors.catFood,
          description: 'Groceries',
          category: 'Food',
        ),
        HistoryTransactionModel(
          id: 'tx_3',
          date: DateTime(2026, 10, 9),
          amount: 900,
          type: TransactionType.spend,
          icon: AppIcons.catFun,
          bgColor: const Color(0xFFFDE8F3),
          iconColor: AppColors.catFun,
          description: 'Movie night',
          category: 'Fun',
        ),
        HistoryTransactionModel(
          id: 'tx_4',
          date: DateTime(2026, 10, 7),
          amount: 2600,
          type: TransactionType.spend,
          icon: AppIcons.catShopping,
          bgColor: const Color(0xFFFDEAEA),
          iconColor: AppColors.catShopping,
          description: 'Sneakers',
          category: 'Shopping',
        ),
        HistoryTransactionModel(
          id: 'tx_5',
          date: DateTime(2026, 10, 6),
          amount: 540,
          type: TransactionType.spend,
          icon: AppIcons.catTravel,
          bgColor: const Color(0xFFE5F5F8),
          iconColor: AppColors.catTravel,
          description: 'Metro recharge',
          category: 'Travel',
        ),
        HistoryTransactionModel(
          id: 'tx_6',
          date: DateTime(2026, 10, 5),
          amount: 14500,
          type: TransactionType.income,
          icon: AppIcons.work,
          bgColor: const Color(0xFFE3F4EA),
          iconColor: AppColors.success,
          description: 'Freelance app design milestone',
          category: 'Side Work',
        ),
        HistoryTransactionModel(
          id: 'tx_7',
          date: DateTime(2026, 10, 4),
          amount: 1850,
          type: TransactionType.spend,
          icon: AppIcons.catFood,
          bgColor: const Color(0xFFFFF1E5),
          iconColor: AppColors.catFood,
          description: 'Dinner with friends',
          category: 'Food',
        ),
        HistoryTransactionModel(
          id: 'tx_8',
          date: DateTime(2026, 10, 3),
          amount: 2100,
          type: TransactionType.spend,
          icon: AppIcons.catBills,
          bgColor: const Color(0xFFECEFFC),
          iconColor: AppColors.catBills,
          description: 'Electricity bill payment',
          category: 'Bills',
        ),
        HistoryTransactionModel(
          id: 'tx_9',
          date: DateTime(2026, 10, 1),
          amount: 55000,
          type: TransactionType.income,
          icon: AppIcons.payments,
          bgColor: const Color(0xFFE3F4EA),
          iconColor: AppColors.success,
          description: 'Monthly salary credited',
          category: 'Salary',
        ),
        HistoryTransactionModel(
          id: 'tx_10',
          date: DateTime(2026, 9, 28),
          amount: 650,
          type: TransactionType.spend,
          icon: AppIcons.catHealth,
          bgColor: const Color(0xFFE6F5EE),
          iconColor: AppColors.catHealth,
          description: 'Pharmacy medicines',
          category: 'Health',
        ),
        HistoryTransactionModel(
          id: 'tx_11',
          date: DateTime(2026, 9, 25),
          amount: 5000,
          type: TransactionType.income,
          icon: AppIcons.gift,
          bgColor: const Color(0xFFFDE8F3),
          iconColor: AppColors.catFun,
          description: 'Birthday gift received',
          category: 'Gift',
        ),
      ];

  /// Alias for backward compatibility.
  static List<HistoryTransactionModel> get sampleTransactions => dummyData;
}
