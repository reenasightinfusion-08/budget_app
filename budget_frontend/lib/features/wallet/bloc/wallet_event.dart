import 'package:flutter/foundation.dart';

import 'package:budget_frontend/features/wallet/models/easy_fix.dart';

@immutable
abstract class WalletEvent {
  const WalletEvent();
}

/// Dispatched when the user updates their monthly budget.
class UpdateMonthlyBudget extends WalletEvent {
  const UpdateMonthlyBudget(this.monthlyBudget);

  final int monthlyBudget;
}

/// Dispatched when a single category limit is edited.
class UpdateCategoryLimit extends WalletEvent {
  const UpdateCategoryLimit({
    required this.categoryId,
    required this.newLimit,
  });

  final String categoryId;
  final int newLimit;
}

/// Dispatched when an Easy Fix suggestion is applied.
class ApplyWalletEasyFix extends WalletEvent {
  const ApplyWalletEasyFix(this.fix);

  final EasyFix fix;
}
