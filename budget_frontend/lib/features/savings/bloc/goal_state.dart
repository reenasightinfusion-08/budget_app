import 'package:flutter/foundation.dart';
import 'package:budget_frontend/features/savings/models/goal_model.dart';

@immutable
class GoalState {
  const GoalState({
    this.goals = const [],
    this.totalSavedRupees = 0,
    this.thisMonthRupees = 0,
    this.totalTargetRupees = 0,
    this.totalMonthlyNeededRupees = 0,
    this.isLoading = false,
    this.isLoaded = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<GoalModel> goals;
  final int totalSavedRupees;
  final int thisMonthRupees;
  final int totalTargetRupees;
  final int totalMonthlyNeededRupees;
  final bool isLoading;
  final bool isLoaded;
  final bool isSubmitting;
  final String? errorMessage;

  GoalState copyWith({
    List<GoalModel>? goals,
    int? totalSavedRupees,
    int? thisMonthRupees,
    int? totalTargetRupees,
    int? totalMonthlyNeededRupees,
    bool? isLoading,
    bool? isLoaded,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      totalSavedRupees: totalSavedRupees ?? this.totalSavedRupees,
      thisMonthRupees: thisMonthRupees ?? this.thisMonthRupees,
      totalTargetRupees: totalTargetRupees ?? this.totalTargetRupees,
      totalMonthlyNeededRupees:
          totalMonthlyNeededRupees ?? this.totalMonthlyNeededRupees,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
