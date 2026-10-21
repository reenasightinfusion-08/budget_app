import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

class GoalContributionModel {
  const GoalContributionModel({
    required this.amountPaise,
    required this.date,
  });

  factory GoalContributionModel.fromJson(Map<String, dynamic> json) {
    return GoalContributionModel(
      amountPaise: (json['amount'] is num) ? (json['amount'] as num).toInt() : 0,
      date: (json['date'] ?? '').toString(),
    );
  }

  final int amountPaise;
  final String date;

  int get amountRupees => amountPaise ~/ 100;
}

class GoalModel {
  const GoalModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.targetAmountPaise,
    required this.targetMonth,
    required this.savedAmountPaise,
    this.reachedAt,
    this.contributions = const [],
    this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final rawContributions = json['contributions'] as List<dynamic>? ?? [];
    final contributions = rawContributions
        .whereType<Map<String, dynamic>>()
        .map(GoalContributionModel.fromJson)
        .toList();

    DateTime? reached;
    if (json['reachedAt'] != null) {
      try {
        reached = DateTime.parse(json['reachedAt'].toString());
      } catch (_) {}
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      try {
        created = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return GoalModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconKey: (json['icon'] ?? 'star').toString(),
      targetAmountPaise:
          (json['targetAmount'] is num) ? (json['targetAmount'] as num).toInt() : 0,
      targetMonth: (json['targetMonth'] ?? '').toString(),
      savedAmountPaise:
          (json['savedAmount'] is num) ? (json['savedAmount'] as num).toInt() : 0,
      reachedAt: reached,
      contributions: contributions,
      createdAt: created,
    );
  }

  final String id;
  final String name;
  final String iconKey; // 'shield', 'phone', 'plane', 'house', 'gift', 'star'
  final int targetAmountPaise;
  final String targetMonth; // YYYY-MM
  final int savedAmountPaise;
  final DateTime? reachedAt;
  final List<GoalContributionModel> contributions;
  final DateTime? createdAt;

  int get targetAmountRupees => targetAmountPaise ~/ 100;
  int get savedAmountRupees => savedAmountPaise ~/ 100;
  int get remainingRupees => (targetAmountRupees - savedAmountRupees).clamp(0, targetAmountRupees);

  double get progressRatio => targetAmountPaise > 0
      ? (savedAmountPaise / targetAmountPaise).clamp(0.0, 1.0)
      : 0.0;

  int get progressPercent => (progressRatio * 100).round();

  bool get isReached => reachedAt != null || savedAmountPaise >= targetAmountPaise;

  /// Formatted month e.g. "Apr 2027" from "2027-04"
  String get formattedTargetMonth {
    if (targetMonth.isEmpty) return '';
    try {
      final parts = targetMonth.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        return '${AppFormatters.monthShort(month)} $year';
      }
    } catch (_) {}
    return targetMonth;
  }

  /// Calculates monthly amount needed from current month to [targetMonth].
  int get monthlyNeededRupees {
    if (isReached || remainingRupees <= 0) return 0;
    try {
      final parts = targetMonth.split('-');
      if (parts.length == 2) {
        final now = DateTime.now();
        final targetYear = int.parse(parts[0]);
        final targetMonthNum = int.parse(parts[1]);
        final monthsLeft = ((targetYear - now.year) * 12 + (targetMonthNum - now.month)).clamp(1, 120);
        return (remainingRupees / monthsLeft).ceil();
      }
    } catch (_) {}
    return remainingRupees;
  }

  IconData get iconData => iconKeyToIcon(iconKey);

  static IconData iconKeyToIcon(String key) => switch (key.toLowerCase()) {
        'shield' => AppIcons.shield,
        'phone' => AppIcons.phone,
        'plane' => AppIcons.plane,
        'house' || 'home' => AppIcons.home,
        'gift' => AppIcons.gift,
        'star' => AppIcons.star,
        _ => AppIcons.star,
      };

  static String iconToIconKey(IconData icon) {
    if (icon == AppIcons.shield) return 'shield';
    if (icon == AppIcons.phone || icon == AppIcons.laptop) return 'phone';
    if (icon == AppIcons.plane) return 'plane';
    if (icon == AppIcons.home) return 'house';
    if (icon == AppIcons.gift) return 'gift';
    return 'star';
  }
}

class GoalsResponseModel {
  const GoalsResponseModel({
    required this.goals,
    required this.totalSavedPaise,
    required this.thisMonthPaise,
  });

  factory GoalsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawGoals = json['goals'] as List<dynamic>? ?? [];
    final goals = rawGoals
        .whereType<Map<String, dynamic>>()
        .map(GoalModel.fromJson)
        .toList();

    // LIFO ordering: last added goal shows on top
    final hasCreatedAt = goals.any((g) => g.createdAt != null);
    final lifoGoals = hasCreatedAt
        ? (List<GoalModel>.from(goals)
          ..sort((a, b) {
            if (a.createdAt != null && b.createdAt != null) {
              return b.createdAt!.compareTo(a.createdAt!);
            }
            return 0;
          }))
        : goals.reversed.toList();

    return GoalsResponseModel(
      goals: lifoGoals,
      totalSavedPaise:
          (json['totalSaved'] is num) ? (json['totalSaved'] as num).toInt() : 0,
      thisMonthPaise:
          (json['thisMonth'] is num) ? (json['thisMonth'] as num).toInt() : 0,
    );
  }

  final List<GoalModel> goals;
  final int totalSavedPaise;
  final int thisMonthPaise;

  int get totalSavedRupees => totalSavedPaise ~/ 100;
  int get thisMonthRupees => thisMonthPaise ~/ 100;
  int get totalTargetRupees => goals.fold(0, (sum, g) => sum + g.targetAmountRupees);
  int get totalMonthlyNeededRupees => goals.fold(0, (sum, g) => sum + g.monthlyNeededRupees);
}
