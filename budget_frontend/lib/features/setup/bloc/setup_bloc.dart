import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/features/setup/bloc/setup_event.dart';
import 'package:budget_frontend/features/setup/bloc/setup_state.dart';
import 'package:budget_frontend/features/setup/models/profile_setup_model.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';

export 'package:budget_frontend/features/setup/bloc/setup_event.dart';
export 'package:budget_frontend/features/setup/bloc/setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  SetupBloc({required this.profileService}) : super(const SetupState()) {
    on<SetupBudgetAmountChanged>(onBudgetAmountChanged);
    on<SetupCompletedSubmitted>(onCompletedSubmitted);
  }

  static const int paisePerRupee = 100;

  final ProfileService profileService;

  void onBudgetAmountChanged(SetupBudgetAmountChanged event, Emitter<SetupState> emit) {
    if (event.amount == state.budgetAmount) return;
    emit(state.copyWith(budgetAmount: event.amount));
  }

  Future<void> onCompletedSubmitted(
    SetupCompletedSubmitted event,
    Emitter<SetupState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final user = await profileService.saveSetup(
        name: event.name,
        monthlyBudgetPaise: state.budgetAmount * paisePerRupee,
      );
      emit(state.copyWith(
        isSaving: false,
        savedUser: user,
        profile: ProfileSetupModel(name: event.name, monthlyBudget: state.budgetAmount),
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.message));
    } catch (e, stack) {
      debugPrint('SetupBloc save error: $e\n$stack');
      emit(state.copyWith(isSaving: false, errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}
