import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/models/month_summary_model.dart';

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

  int get previousMonthSavePercentage => previousMonthIncome > 0
      ? (previousMonthSaved / previousMonthIncome * 100).round()
      : 0;

  int get maxCategoryAmount =>
      categorySpends.fold(1, (max, c) => math.max(max, c.amount));

  /// Empty insights when no live transaction data is available.
  factory InsightsData.empty(int budget) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day.clamp(1, daysInMonth);

    return InsightsData(
      budget: budget,
      spentThisMonth: 0,
      daysInMonth: daysInMonth,
      currentDay: currentDay,
      cumulativeSpending: const [],
      monthlyRecords: const [],
      categorySpends: const [],
      previousMonthSaved: 0,
      previousMonthName: AppFormatters.monthName(
        DateTime(now.year, now.month - 1).month,
      ),
      previousMonthIncome: 0,
    );
  }

  /// Builds insights from live API transaction summary.
  factory InsightsData.fromSummaryAndBudget(
    MonthSummaryModel summary,
    int budget,
  ) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day.clamp(1, daysInMonth);

    // Map daily spending for cumulative curve
    final dailyMap = {for (final d in summary.daily) d.date: d.spentRupees};
    final cumulative = <double>[];
    var running = 0.0;
    for (var d = 1; d <= currentDay; d++) {
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      running += dailyMap[dateStr] ?? 0;
      cumulative.add(running);
    }

    // 6-month historical bars
    final monthlyRecords = summary.months.map((m) {
      DateTime? parsed;
      try {
        parsed = DateTime.parse('${m.month}-01');
      } catch (_) {}
      final monthName = parsed != null
          ? AppFormatters.monthShort(parsed.month)
          : m.month;
      return MonthlyRecord(
        month: monthName,
        income: m.incomeRupees,
        expense: m.expenseRupees,
        isCurrent: m.month == summary.month,
      );
    }).toList();

    // Category breakdown
    final expenseCategories =
        summary.byCategory
            .where((c) => c.type == 'expense' && c.totalPaise > 0)
            .toList()
          ..sort((a, b) => b.totalPaise.compareTo(a.totalPaise));

    final totalSpent = summary.expenseRupees;
    final categorySpends = expenseCategories.map((c) {
      return CategorySpend(
        name: HistoryTransactionModel.categoryKeyToLabel(c.category),
        amount: c.totalRupees,
        totalSpent: totalSpent,
        color: HistoryTransactionModel.categoryKeyToColor(c.category),
        icon: HistoryTransactionModel.categoryKeyToIcon(c.category),
      );
    }).toList();

    // Previous month comparison
    SummaryMonthItem? prevMonth;
    if (summary.months.length >= 2) {
      prevMonth = summary.months[summary.months.length - 2];
    }
    final prevIncome = prevMonth?.incomeRupees ?? 0;
    final prevExpense = prevMonth?.expenseRupees ?? 0;
    final prevSaved = (prevIncome - prevExpense)
        .clamp(0, double.infinity)
        .toInt();

    return InsightsData(
      budget: budget,
      spentThisMonth: totalSpent,
      daysInMonth: daysInMonth,
      currentDay: currentDay,
      cumulativeSpending: cumulative,
      monthlyRecords: monthlyRecords,
      categorySpends: categorySpends,
      previousMonthSaved: prevSaved,
      previousMonthName: AppFormatters.monthName(
        DateTime(now.year, now.month - 1).month,
      ),
      previousMonthIncome: prevIncome,
    );
  }
}
