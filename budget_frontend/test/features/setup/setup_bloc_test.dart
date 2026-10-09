import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

void main() {
  late SetupBloc setupBloc;

  setUp(() {
    setupBloc = SetupBloc();
  });

  tearDown(() {
    setupBloc.close();
  });

  test('initial state is incomplete with zero budget', () {
    expect(setupBloc.state.budgetAmount, 0);
    expect(setupBloc.state.isComplete, false);
    expect(setupBloc.state.dailyAllowanceLabel, isNull);
  });

  test('updating budget amount calculates daily allowance label', () async {
    final expectation = expectLater(
      setupBloc.stream,
      emits(
        predicate<SetupState>((state) =>
            state.budgetAmount == 30000 &&
            state.dailyAllowanceLabel != null &&
            state.dailyAllowanceLabel!.contains('1,000')),
      ),
    );

    setupBloc.add(const SetupBudgetAmountChanged(30000));
    await expectation;
  });

  test('submitting setup completes profile', () async {
    setupBloc.add(const SetupBudgetAmountChanged(15000));

    final expectation = expectLater(
      setupBloc.stream,
      emitsThrough(
        predicate<SetupState>((state) =>
            state.isComplete &&
            state.profile?.name == 'Alex' &&
            state.profile?.monthlyBudget == 15000),
      ),
    );

    setupBloc.add(const SetupCompletedSubmitted(name: 'Alex'));
    await expectation;
  });
}
