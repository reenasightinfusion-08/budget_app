import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_event.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_state.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';

export 'package:budget_frontend/features/wallet/bloc/wallet_event.dart';
export 'package:budget_frontend/features/wallet/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({int initialBudget = AppConfig.defaultMonthlyBudget})
      : super(WalletState(
          monthlyBudget: initialBudget,
          categories: BudgetCategoryModel.generateInitial(initialBudget),
        )) {
    on<UpdateMonthlyBudget>(_onUpdateMonthlyBudget);
    on<UpdateCategoryLimit>(_onUpdateCategoryLimit);
    on<ApplyWalletEasyFix>(_onApplyWalletEasyFix);
  }

  void _onUpdateMonthlyBudget(
    UpdateMonthlyBudget event,
    Emitter<WalletState> emit,
  ) {
    if (event.monthlyBudget <= 0) return;
    final updatedCategories = BudgetCategoryModel.generateInitial(event.monthlyBudget);
    emit(state.copyWith(
      monthlyBudget: event.monthlyBudget,
      categories: updatedCategories,
    ));
  }

  void _onUpdateCategoryLimit(
    UpdateCategoryLimit event,
    Emitter<WalletState> emit,
  ) {
    final updated = state.categories.map((c) {
      if (c.id == event.categoryId) {
        c.limit = event.newLimit;
      }
      return c;
    }).toList();
    emit(state.copyWith(categories: updated));
  }

  void _onApplyWalletEasyFix(
    ApplyWalletEasyFix event,
    Emitter<WalletState> emit,
  ) {
    event.fix.from.limit -= event.fix.amount;
    event.fix.to.limit += event.fix.amount;
    emit(state.copyWith(categories: List.of(state.categories)));
  }
}
