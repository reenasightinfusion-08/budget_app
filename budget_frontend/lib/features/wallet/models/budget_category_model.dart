import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

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

  /// Sample plan with spend and limits scaled from the default budget to [totalBudget].
  static List<BudgetCategoryModel> generateInitial(int totalBudget) {
    final factor = totalBudget / AppConfig.defaultMonthlyBudget;

    BudgetCategoryModel category(
      String id,
      String label,
      IconData icon,
      Color color,
      int spent,
      int limit,
    ) => BudgetCategoryModel(
      id: id,
      label: label,
      icon: icon,
      color: color,
      spent: (spent * factor).round(),
      limit: (limit * factor).round(),
    );

    return [
      category('food', 'Food', Icons.restaurant_rounded, AppColors.catFood, 5990, 7000),
      category('bills', 'Bills', Icons.receipt_long_rounded, AppColors.catBills, 5400, 6000),
      category('travel', 'Travel', Icons.directions_car_rounded, AppColors.catTravel, 4000, 4500),
      category('shopping', 'Shopping', Icons.shopping_bag_rounded, AppColors.catShopping, 4500, 4000),
      category('home', 'Home', Icons.home_rounded, AppColors.catHome, 1500, 2500),
      category('health', 'Health', Icons.favorite_rounded, AppColors.catHealth, 700, 1500),
      category('fun', 'Fun', Icons.sports_esports_rounded, AppColors.catFun, 2100, 2500),
      category('other', 'Other', Icons.more_horiz_rounded, AppColors.catOther, 0, 2000),
    ];
  }
}
