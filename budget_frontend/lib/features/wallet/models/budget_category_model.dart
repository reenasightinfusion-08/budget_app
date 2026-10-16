import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

import 'package:budget_frontend/features/categories/models/category_model.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';

enum BudgetStatus { onTrack, careful, over }

class BudgetCategoryModel {
  BudgetCategoryModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.spent,
    required this.limit,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  int spent;
  int limit;

  int get remaining => limit - spent;

  BudgetStatus get status {
    if (limit > 0 && spent > limit) return BudgetStatus.over;
    if (limit > 0 && spent / limit >= 0.85) return BudgetStatus.careful;
    return BudgetStatus.onTrack;
  }

  String get statusText => switch (status) {
    BudgetStatus.over => 'Over by ${AppFormatters.rupees(-remaining)}',
    BudgetStatus.careful => 'Only ${AppFormatters.rupees(remaining)} left',
    BudgetStatus.onTrack => '${AppFormatters.rupees(remaining)} left',
  };

  double get progressRatio {
    if (limit <= 0) return spent > 0 ? 1.0 : 0.0;
    return (spent / limit).clamp(0.0, 1.0);
  }

  factory BudgetCategoryModel.fromCategoryModel(
    CategoryModel cat, {
    int spent = 0,
    int limit = 0,
  }) {
    return BudgetCategoryModel(
      id: cat.key,
      label: cat.label,
      icon: cat.icon,
      color: cat.color,
      spent: spent,
      limit: limit,
    );
  }

  static const Map<String, int> _defaultLimits = {
    'food': 7000,
    'bills': 6000,
    'travel': 4500,
    'shopping': 4000,
    'home': 2500,
    'health': 1500,
    'fun': 2500,
    'other': 2000,
  };

  /// Generates budget category models dynamically from API categories ([liveCategories] or [CategoryRegistry.expenses]).
  static List<BudgetCategoryModel> generateInitial(
    int totalBudget, [
    Map<String, int>? customLimitsPaise,
    List<CategoryModel>? liveCategories,
  ]) {
    final factor = totalBudget / AppConfig.defaultMonthlyBudget;
    final sourceList = (liveCategories != null && liveCategories.isNotEmpty)
        ? liveCategories.where((c) => c.isExpense).toList()
        : CategoryRegistry.expenses;

    if (sourceList.isEmpty) return const [];

    return sourceList.map((cat) {
      final int defaultLimit = _defaultLimits[cat.key] ?? 2000;
      final int effectiveLimit = (customLimitsPaise != null &&
              customLimitsPaise.containsKey(cat.key))
          ? (customLimitsPaise[cat.key]! ~/ 100)
          : (defaultLimit * factor).round();

      return BudgetCategoryModel(
        id: cat.key,
        label: cat.label,
        icon: cat.icon,
        color: cat.color,
        spent: 0,
        limit: effectiveLimit,
      );
    }).toList();
  }

  /// Builds income category models dynamically from API categories ([CategoryRegistry.incomes]).
  static List<BudgetCategoryModel> defaultIncomeCategories([
    List<CategoryModel>? liveCategories,
  ]) {
    final sourceList = (liveCategories != null && liveCategories.isNotEmpty)
        ? liveCategories.where((c) => c.isIncome).toList()
        : CategoryRegistry.incomes;

    return sourceList
        .map((cat) => BudgetCategoryModel.fromCategoryModel(cat))
        .toList();
  }
}
