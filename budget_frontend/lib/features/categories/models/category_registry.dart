import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/features/categories/models/category_model.dart';

/// In-memory category cache populated solely from `GET /api/categories`.
/// Contains zero hardcoded category entries.
class CategoryRegistry {
  CategoryRegistry._();

  static List<CategoryModel> _categories = const [];

  /// Updates the cache with categories fetched directly from `GET /api/categories`.
  static void setCategories(List<CategoryModel> categories) {
    _categories = List.unmodifiable(categories);
  }

  /// All categories fetched from API.
  static List<CategoryModel> get all => _categories;

  /// All expense categories from API.
  static List<CategoryModel> get expenses =>
      _categories.where((c) => c.isExpense).toList();

  /// All income categories from API.
  static List<CategoryModel> get incomes =>
      _categories.where((c) => c.isIncome).toList();

  /// Finds category by key and optional type directly from API data.
  static CategoryModel? find(String key, [String? type]) {
    final lowerKey = key.toLowerCase().trim();
    if (type != null) {
      final lowerType = type.toLowerCase().trim();
      for (final c in _categories) {
        if (c.key == lowerKey && c.type == lowerType) return c;
      }
    }
    for (final c in _categories) {
      if (c.key == lowerKey) return c;
    }
    return null;
  }

  /// Returns the API label for a category key (e.g. 'Food', 'Side work').
  static String getLabel(String key, [String? type]) {
    final cat = find(key, type);
    if (cat != null) return cat.label;
    if (key.trim().isEmpty) return 'Other';
    final clean = key.trim();
    return '${clean[0].toUpperCase()}${clean.substring(1)}';
  }

  /// Returns the category icon from API data.
  static IconData getIcon(String key, [String? type]) {
    final cat = find(key, type);
    return cat?.icon ?? AppIcons.moreHoriz;
  }

  /// Returns the Color parsed directly from API hex code (e.g. '#E8913A').
  static Color getColor(String key, [String? type, bool isIncome = false]) {
    final cat = find(key, type ?? (isIncome ? 'income' : 'expense'));
    if (cat != null) return cat.color;
    return isIncome ? AppColors.success : AppColors.catOther;
  }

  /// Returns the category type ('expense' or 'income').
  static String getType(String key) {
    final cat = find(key);
    return cat?.type ?? 'expense';
  }

  /// Returns the raw color hex code from the API (e.g. '#E8913A').
  static String? getColorHex(String key, [String? type]) {
    final cat = find(key, type);
    return cat?.colorHex;
  }
}
