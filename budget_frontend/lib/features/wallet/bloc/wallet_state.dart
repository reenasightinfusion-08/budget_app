import 'package:flutter/foundation.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/models/easy_fix.dart';

@immutable
class WalletState {
  const WalletState({
    this.monthlyBudget = AppConfig.defaultMonthlyBudget,
    this.categories = const [],
  });

  /// The monthly budget amount in Rupees (default 30000).
  /// Available across screens via `context.watch<WalletBloc>().state.monthlyBudget`.
  final int monthlyBudget;

  final List<BudgetCategoryModel> categories;

  int get plannedTotal => categories.fold(0, (sum, c) => sum + c.limit);

  int countWithStatus(BudgetStatus status) =>
      categories.where((c) => c.status == status).length;

  EasyFix? get easyFix => EasyFix.find(categories);

  WalletState copyWith({
    int? monthlyBudget,
    List<BudgetCategoryModel>? categories,
  }) {
    return WalletState(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      categories: categories ?? this.categories,
    );
  }
}
