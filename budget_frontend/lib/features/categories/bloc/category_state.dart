import 'package:flutter/material.dart';
import 'package:budget_frontend/features/categories/models/category_model.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';

@immutable
class CategoryState {
  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
  });

  final List<CategoryModel> categories;
  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;

  List<CategoryModel> get expenseCategories => categories.isNotEmpty
      ? categories.where((c) => c.isExpense).toList()
      : CategoryRegistry.expenses;

  List<CategoryModel> get incomeCategories => categories.isNotEmpty
      ? categories.where((c) => c.isIncome).toList()
      : CategoryRegistry.incomes;

  CategoryModel? find(String key, [String? type]) {
    final list = categories.isNotEmpty ? categories : CategoryRegistry.all;
    final lowerKey = key.toLowerCase().trim();
    if (type != null) {
      final lowerType = type.toLowerCase().trim();
      for (final c in list) {
        if (c.key == lowerKey && c.type == lowerType) return c;
      }
    }
    for (final c in list) {
      if (c.key == lowerKey) return c;
    }
    return null;
  }

  String labelFor(String key, [String? type]) =>
      find(key, type)?.label ?? CategoryRegistry.getLabel(key, type);

  IconData iconFor(String key, [String? type]) =>
      find(key, type)?.icon ?? CategoryRegistry.getIcon(key, type);

  Color colorFor(String key, [String? type, bool isIncome = false]) =>
      find(key, type)?.color ?? CategoryRegistry.getColor(key, type, isIncome);

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    bool? isLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
