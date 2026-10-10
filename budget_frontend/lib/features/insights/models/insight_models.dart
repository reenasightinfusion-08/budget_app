import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';

class CategorySpend {
  const CategorySpend({
    required this.name,
    required this.amount,
    required this.totalSpent,
    required this.color,
    required this.icon,
  });

  final String name;
  final int amount;
  final int totalSpent;
  final Color color;
  final IconData icon;

  double get percentage => totalSpent > 0 ? amount / totalSpent : 0.0;
  int get percentageInt => (percentage * 100).round();
}

class MonthlyRecord {
  const MonthlyRecord({
    required this.month,
    required this.income,
    required this.expense,
    this.isCurrent = false,
  });

  final String month;
  final int income;
  final int expense;
  final bool isCurrent;
}

class InsightsData {
  const InsightsData({
    required this.budget,
    required this.spentThisMonth,
    required this.daysInMonth,
    required this.currentDay,
    required this.cumulativeSpending,
    required this.monthlyRecords,
    required this.categorySpends,
    required this.previousMonthSaved,
    required this.previousMonthName,
    required this.previousMonthIncome,
  });

  final int budget;
  final int spentThisMonth;
  final int daysInMonth;
  final int currentDay;
  final List<double> cumulativeSpending;
  final List<MonthlyRecord> monthlyRecords;
  final List<CategorySpend> categorySpends;
  final int previousMonthSaved;
  final String previousMonthName;
  final int previousMonthIncome;

  /// Spent so far minus what an even daily pace of the budget would have spent by today.
  double get paceDiff => spentThisMonth - (budget / daysInMonth) * currentDay;

  bool get isUnderPace => paceDiff <= 0;

  int get previousMonthSavePercentage =>
      previousMonthIncome > 0 ? (previousMonthSaved / previousMonthIncome * 100).round() : 0;

  int get maxCategoryAmount => categorySpends.fold(1, (max, c) => math.max(max, c.amount));

  static const List<int> dailyIncrements = [
    3200, 1800, 400, 1200, 240, 2600, 300, 900, 150, 1600,
    500, 2200, 350, 1800, 200, 700, 650, 400, 1900, 300,
    1500, 200, 1700, 350, 1000, 450, 1200, 300, 500, 200, 300,
  ];
  static const List<int> sixMonthIncome = [52000, 58000, 52000, 58000, 52000, 58000];
  static const List<int> sixMonthExpense = [28500, 31200, 27400, 34200, 29800, 18400];

  /// Sample data until real transactions are wired in, scaled from the default budget to [budget].
  factory InsightsData.mockForBudget(int budget) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day.clamp(1, daysInMonth);
    final factor = budget / AppConfig.defaultMonthlyBudget;

    final cumulative = <double>[];
    var running = 0.0;
    for (var day = 0; day < currentDay; day++) {
      running += dailyIncrements[day % dailyIncrements.length] * factor;
      cumulative.add(running);
    }
    final spent = running.round();

    final monthlyRecords = List.generate(6, (i) {
      final isCurrent = i == 5;
      return MonthlyRecord(
        month: AppFormatters.monthShort(DateTime(now.year, now.month - 5 + i).month),
        income: (sixMonthIncome[i] * factor).round(),
        expense: isCurrent ? spent : (sixMonthExpense[i] * factor).round(),
        isCurrent: isCurrent,
      );
    });

    final spendingCategories = BudgetCategoryModel.generateInitial(budget)
        .where((c) => c.spent > 0)
        .toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    return InsightsData(
      budget: budget,
      spentThisMonth: spent,
      daysInMonth: daysInMonth,
      currentDay: currentDay,
      cumulativeSpending: cumulative,
      monthlyRecords: monthlyRecords,
      categorySpends: [
        for (final c in spendingCategories)
          CategorySpend(
            name: c.label,
            amount: c.spent,
            totalSpent: spent,
            color: c.color,
            icon: c.icon,
          ),
      ],
      previousMonthSaved: (14500 * factor).round(),
      previousMonthName: AppFormatters.monthName(DateTime(now.year, now.month - 1).month),
      previousMonthIncome: (52000 * factor).round(),
    );
  }
}
