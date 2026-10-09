import 'package:flutter/foundation.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/setup/models/profile_setup_model.dart';

@immutable
class SetupState {
  static const int daysInMonth = 30;

  const SetupState({
    this.budgetAmount = 0,
    this.profile,
  });

  final int budgetAmount;
  final ProfileSetupModel? profile;

  bool get isComplete => profile != null;

  String? get dailyAllowanceLabel => budgetAmount > 0
      ? '${AppFormatters.rupees((budgetAmount / daysInMonth).round())} a day'
      : null;

  SetupState copyWith({
    int? budgetAmount,
    ProfileSetupModel? profile,
  }) {
    return SetupState(
      budgetAmount: budgetAmount ?? this.budgetAmount,
      profile: profile ?? this.profile,
    );
  }
}
