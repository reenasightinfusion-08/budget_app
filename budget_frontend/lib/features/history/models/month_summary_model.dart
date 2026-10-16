import 'package:budget_frontend/features/history/models/history_transaction_model.dart';

class SummaryCategoryItem {
  const SummaryCategoryItem({
    required this.type,
    required this.category,
    required this.totalPaise,
  });

  factory SummaryCategoryItem.fromJson(Map<String, dynamic> json) {
    return SummaryCategoryItem(
      type: (json['type'] ?? 'expense').toString(),
      category: (json['category'] ?? '').toString(),
      totalPaise: (json['total'] is num) ? (json['total'] as num).toInt() : 0,
    );
  }

  final String type;
  final String category;
  final int totalPaise;

  int get totalRupees => totalPaise ~/ 100;
}

class SummaryDailyItem {
  const SummaryDailyItem({
    required this.date,
    required this.spentPaise,
  });

  factory SummaryDailyItem.fromJson(Map<String, dynamic> json) {
    return SummaryDailyItem(
      date: (json['date'] ?? '').toString(),
      spentPaise: (json['spent'] is num) ? (json['spent'] as num).toInt() : 0,
    );
  }

  final String date;
  final int spentPaise;

  int get spentRupees => spentPaise ~/ 100;
}

class SummaryMonthItem {
  const SummaryMonthItem({
    required this.month,
    required this.incomePaise,
    required this.expensePaise,
  });

  factory SummaryMonthItem.fromJson(Map<String, dynamic> json) {
    return SummaryMonthItem(
      month: (json['month'] ?? '').toString(),
      incomePaise: (json['income'] is num) ? (json['income'] as num).toInt() : 0,
      expensePaise: (json['expense'] is num) ? (json['expense'] as num).toInt() : 0,
    );
  }

  final String month;
  final int incomePaise;
  final int expensePaise;

  int get incomeRupees => incomePaise ~/ 100;
  int get expenseRupees => expensePaise ~/ 100;
}

class SummaryCounts {
  const SummaryCounts({
    required this.entries,
    required this.months,
  });

  factory SummaryCounts.fromJson(Map<String, dynamic> json) {
    return SummaryCounts(
      entries: (json['entries'] is num) ? (json['entries'] as num).toInt() : 0,
      months: (json['months'] is num) ? (json['months'] as num).toInt() : 0,
    );
  }

  final int entries;
  final int months;
}

class MonthSummaryModel {
  const MonthSummaryModel({
    required this.month,
    required this.today,
    required this.incomePaise,
    required this.expensePaise,
    required this.byCategory,
    required this.weekStart,
    required this.daily,
    required this.previousMonthSoFarPaise,
    required this.months,
    required this.recent,
    required this.counts,
  });

  factory MonthSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawByCategory = json['byCategory'] as List<dynamic>? ?? [];
    final byCategory = rawByCategory
        .whereType<Map<String, dynamic>>()
        .map(SummaryCategoryItem.fromJson)
        .toList();

    final rawDaily = json['daily'] as List<dynamic>? ?? [];
    final daily = rawDaily
        .whereType<Map<String, dynamic>>()
        .map(SummaryDailyItem.fromJson)
        .toList();

    final rawMonths = json['months'] as List<dynamic>? ?? [];
    final months = rawMonths
        .whereType<Map<String, dynamic>>()
        .map(SummaryMonthItem.fromJson)
        .toList();

    final rawRecent = json['recent'] as List<dynamic>? ?? [];
    final recent = rawRecent
        .whereType<Map<String, dynamic>>()
        .map(HistoryTransactionModel.fromJson)
        .toList();

    recent.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      if (b.createdAt != null && a.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });

    final countsJson = json['counts'] as Map<String, dynamic>? ?? {};

    return MonthSummaryModel(
      month: (json['month'] ?? '').toString(),
      today: (json['today'] ?? '').toString(),
      incomePaise: (json['income'] is num) ? (json['income'] as num).toInt() : 0,
      expensePaise: (json['expense'] is num) ? (json['expense'] as num).toInt() : 0,
      byCategory: byCategory,
      weekStart: (json['weekStart'] ?? '').toString(),
      daily: daily,
      previousMonthSoFarPaise:
          (json['previousMonthSoFar'] is num) ? (json['previousMonthSoFar'] as num).toInt() : 0,
      months: months,
      recent: recent,
      counts: SummaryCounts.fromJson(countsJson),
    );
  }

  final String month;
  final String today;
  final int incomePaise;
  final int expensePaise;
  final List<SummaryCategoryItem> byCategory;
  final String weekStart;
  final List<SummaryDailyItem> daily;
  final int previousMonthSoFarPaise;
  final List<SummaryMonthItem> months;
  final List<HistoryTransactionModel> recent;
  final SummaryCounts counts;

  int get incomeRupees => incomePaise ~/ 100;
  int get expenseRupees => expensePaise ~/ 100;
  int get previousMonthSoFarRupees => previousMonthSoFarPaise ~/ 100;

  /// Map of category key -> expense in Rupees
  Map<String, int> get expenseByCategoryMap {
    final map = <String, int>{};
    for (final item in byCategory) {
      if (item.type == 'expense') {
        map[item.category] = item.totalRupees;
      }
    }
    return map;
  }

  /// Highest spending expense category
  SummaryCategoryItem? get topExpenseCategory {
    final expenseCategories = byCategory.where((c) => c.type == 'expense' && c.totalPaise > 0).toList();
    if (expenseCategories.isEmpty) return null;
    expenseCategories.sort((a, b) => b.totalPaise.compareTo(a.totalPaise));
    return expenseCategories.first;
  }
}
