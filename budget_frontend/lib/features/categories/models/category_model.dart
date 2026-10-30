import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';

class CategoryModel {
  const CategoryModel({
    required this.key,
    required this.type,
    required this.label,
    required this.iconName,
    this.colorHex,
    this.sortOrder = 0,
  });

  final String key;
  final String type; // 'expense' or 'income'
  final String label;
  final String iconName;
  final String? colorHex;
  final int sortOrder;

  bool get isExpense => type.toLowerCase() == 'expense';
  bool get isIncome => type.toLowerCase() == 'income';

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      key: (json['key'] ?? '').toString().toLowerCase().trim(),
      type: (json['type'] ?? 'expense').toString().toLowerCase().trim(),
      label: (json['label'] ?? '').toString().trim(),
      iconName: (json['icon'] ?? '').toString().toLowerCase().trim(),
      colorHex: json['color'] as String?,
      sortOrder: (json['sortOrder'] is num)
          ? (json['sortOrder'] as num).toInt()
          : 0,
    );
  }

  IconData get icon {
    final search = iconName.isNotEmpty ? iconName : key;
    return switch (search) {
      'food' => AppIcons.catFood,
      'bills' => AppIcons.catBills,
      'travel' => AppIcons.catTravel,
      'shopping' => AppIcons.catShopping,
      'home' || 'house' => AppIcons.catHome,
      'health' => AppIcons.catHealth,
      'fun' => AppIcons.catFun,
      'salary' || 'payments' => AppIcons.payments,
      'freelance' || 'work' => AppIcons.work,
      'gift' => AppIcons.gift,
      _ => AppIcons.moreHoriz,
    };
  }

  Color get color {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try {
        final clean = colorHex!.replaceAll('#', '');
        if (clean.length == 6) {
          return Color(int.parse('0xFF$clean'));
        }
      } catch (_) {}
    }
    return switch (key) {
      'food' => AppColors.catFood,
      'bills' => AppColors.catBills,
      'travel' => AppColors.catTravel,
      'shopping' => AppColors.catShopping,
      'home' => AppColors.catHome,
      'health' => AppColors.catHealth,
      'fun' => AppColors.catFun,
      'salary' => AppColors.success,
      'freelance' => AppColors.catBills,
      'gift' => AppColors.catFun,
      _ => (isIncome ? AppColors.success : AppColors.catOther),
    };
  }
}
