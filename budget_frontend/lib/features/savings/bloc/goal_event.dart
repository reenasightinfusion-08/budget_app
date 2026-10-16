import 'package:flutter/foundation.dart';

@immutable
sealed class GoalEvent {
  const GoalEvent();
}

final class LoadGoals extends GoalEvent {
  const LoadGoals({this.month});
  final String? month;
}

final class CreateGoalEvent extends GoalEvent {
  const CreateGoalEvent({
    required this.name,
    required this.icon,
    required this.targetAmountPaise,
    required this.targetMonth,
  });

  final String name;
  final String icon;
  final int targetAmountPaise;
  final String targetMonth;
}

final class AddGoalContributionEvent extends GoalEvent {
  const AddGoalContributionEvent({
    required this.goalId,
    required this.amountPaise,
    required this.date,
    required this.today,
  });

  final String goalId;
  final int amountPaise;
  final String date;
  final String today;
}

final class DeleteGoalEvent extends GoalEvent {
  const DeleteGoalEvent(this.goalId);
  final String goalId;
}
