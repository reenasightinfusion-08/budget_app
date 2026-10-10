import 'package:flutter/foundation.dart';

@immutable
sealed class SetupEvent {
  const SetupEvent();
}

final class SetupBudgetAmountChanged extends SetupEvent {
  const SetupBudgetAmountChanged(this.amount);

  final int amount;
}

final class SetupCompletedSubmitted extends SetupEvent {
  const SetupCompletedSubmitted({required this.name});

  final String name;
}

final class SetupReset extends SetupEvent {
  const SetupReset();
}
