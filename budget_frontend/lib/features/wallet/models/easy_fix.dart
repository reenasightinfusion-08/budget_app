import 'dart:math' as math;

import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';

/// A suggested move of budget from a category with room to one that is overspent.
class EasyFix {
  const EasyFix({required this.from, required this.to, required this.amount});

  final BudgetCategoryModel from;
  final BudgetCategoryModel to;
  final int amount;

  /// Picks the most overspent category and the on-track one best placed to cover it, or null if none can.
  static EasyFix? find(List<BudgetCategoryModel> categories) {
    final overspent = categories.where((c) => c.status == BudgetStatus.over).toList()
      ..sort((a, b) => a.remaining.compareTo(b.remaining));
    final spare = categories.where((c) => c.status == BudgetStatus.onTrack).toList()
      ..sort((a, b) => b.remaining.compareTo(a.remaining));
    if (overspent.isEmpty || spare.isEmpty) return null;

    final target = overspent.first;
    final needed = -target.remaining;
    final source = spare.firstWhere((c) => c.remaining >= needed, orElse: () => spare.first);
    if (source.remaining <= 0) return null;

    return EasyFix(from: source, to: target, amount: math.min(needed, source.remaining));
  }
}
