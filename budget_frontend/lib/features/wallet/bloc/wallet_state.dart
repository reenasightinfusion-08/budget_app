import 'package:flutter/foundation.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/features/history/models/month_summary_model.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/models/easy_fix.dart';

@immutable
class WalletState {
  const WalletState({
    this.monthlyBudget = AppConfig.defaultMonthlyBudget,
    this.categories = const [],
    this.summary,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  /// The monthly budget amount in Rupees (default 30000).
  /// Available across screens via `context.watch<WalletBloc>().state.monthlyBudget`.
  final int monthlyBudget;

  final List<BudgetCategoryModel> categories;
  final MonthSummaryModel? summary;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  int get plannedTotal => categories.fold(0, (sum, c) => sum + c.limit);

  int get totalSpent => summary != null
      ? summary!.expenseRupees
      : categories.fold(0, (sum, c) => sum + c.spent);

  int get remainingBudget => monthlyBudget - totalSpent;

  int get availableToSpend => (monthlyBudget - totalSpent).clamp(0, monthlyBudget);

  double get spendProgress {
    if (monthlyBudget <= 0) return 0.0;
    return (totalSpent / monthlyBudget).clamp(0.0, 1.0);
  }

  int countWithStatus(BudgetStatus status) =>
      categories.where((c) => c.status == status).length;

  EasyFix? get easyFix => EasyFix.find(categories);

  WalletState copyWith({
    int? monthlyBudget,
    List<BudgetCategoryModel>? categories,
    MonthSummaryModel? summary,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      categories: categories ?? this.categories,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

