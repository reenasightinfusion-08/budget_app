import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/features/savings/bloc/goal_event.dart';
import 'package:budget_frontend/features/savings/bloc/goal_state.dart';
import 'package:budget_frontend/features/savings/services/goal_service.dart';

export 'package:budget_frontend/features/savings/bloc/goal_event.dart';
export 'package:budget_frontend/features/savings/bloc/goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc({required this.goalService}) : super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<CreateGoalEvent>(_onCreateGoal);
    on<AddGoalContributionEvent>(_onAddContribution);
    on<DeleteGoalEvent>(_onDeleteGoal);
    on<ResetGoals>((event, emit) => emit(const GoalState()));
  }

  final GoalService goalService;

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    if (!state.isLoaded) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    try {
      final res = await goalService.getGoals(month: event.month);
      emit(
        state.copyWith(
          goals: res.goals,
          totalSavedRupees: res.totalSavedRupees,
          thisMonthRupees: res.thisMonthRupees,
          totalTargetRupees: res.totalTargetRupees,
          totalMonthlyNeededRupees: res.totalMonthlyNeededRupees,
          isLoading: false,
          isLoaded: true,
        ),
      );
    } catch (e) {
      debugPrint('LoadGoals error: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load savings goals',
        ),
      );
    }
  }

  Future<void> _onCreateGoal(
    CreateGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await goalService.createGoal(
        name: event.name,
        icon: event.icon,
        targetAmountPaise: event.targetAmountPaise,
        targetMonth: event.targetMonth,
      );
      emit(state.copyWith(isSubmitting: false));
      // Reload goals list after creation
      add(const LoadGoals());
    } on ApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      debugPrint('CreateGoal error: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to create goal',
        ),
      );
    }
  }

  Future<void> _onAddContribution(
    AddGoalContributionEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await goalService.addContribution(
        goalId: event.goalId,
        amountPaise: event.amountPaise,
        date: event.date,
        today: event.today,
      );
      emit(state.copyWith(isSubmitting: false));
      // Reload goals list after contribution
      add(const LoadGoals());
    } on ApiException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      debugPrint('AddGoalContribution error: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to update goal amount',
        ),
      );
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await goalService.deleteGoal(event.goalId);
      emit(state.copyWith(isSubmitting: false));
      // Reload goals list after deletion
      add(const LoadGoals());
    } catch (e) {
      debugPrint('DeleteGoal error: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to delete goal',
        ),
      );
    }
  }
}
