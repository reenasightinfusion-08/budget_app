import 'package:flutter/foundation.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/setup/models/profile_setup_model.dart';

@immutable
class SetupState {
  static const int daysInMonth = 30;

  const SetupState({
    this.budgetAmount = 0,
    this.profile,
    this.savedUser,
    this.isSaving = false,
    this.errorMessage,
  });

  final int budgetAmount;
  final ProfileSetupModel? profile;
  final UserModel? savedUser;
  final bool isSaving;
  final String? errorMessage;

  bool get isComplete => profile != null;

  int get effectiveBudget => budgetAmount > 0 ? budgetAmount : AppConfig.defaultMonthlyBudget;

  String? get dailyAllowanceLabel => budgetAmount > 0
      ? '${AppFormatters.rupees((budgetAmount / daysInMonth).round())} a day'
      : null;

  SetupState copyWith({
    int? budgetAmount,
    ProfileSetupModel? profile,
    UserModel? savedUser,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SetupState(
      budgetAmount: budgetAmount ?? this.budgetAmount,
      profile: profile ?? this.profile,
      savedUser: savedUser ?? this.savedUser,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
