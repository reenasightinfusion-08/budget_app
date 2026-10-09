import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/features/setup/bloc/setup_event.dart';
import 'package:budget_frontend/features/setup/bloc/setup_state.dart';
import 'package:budget_frontend/features/setup/models/profile_setup_model.dart';

export 'package:budget_frontend/features/setup/bloc/setup_event.dart';
export 'package:budget_frontend/features/setup/bloc/setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  SetupBloc() : super(const SetupState()) {
    on<SetupBudgetAmountChanged>(_onBudgetAmountChanged);
    on<SetupCompletedSubmitted>(_onCompletedSubmitted);
  }

  void _onBudgetAmountChanged(
    SetupBudgetAmountChanged event,
    Emitter<SetupState> emit,
  ) {
    if (event.amount == state.budgetAmount) return;
    emit(state.copyWith(budgetAmount: event.amount));
  }

  void _onCompletedSubmitted(
    SetupCompletedSubmitted event,
    Emitter<SetupState> emit,
  ) {
    final profile = ProfileSetupModel(
      name: event.name,
      monthlyBudget: state.budgetAmount,
    );
    emit(state.copyWith(profile: profile));
  }
}
