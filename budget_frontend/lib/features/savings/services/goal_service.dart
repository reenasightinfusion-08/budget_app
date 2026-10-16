import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/savings/models/goal_model.dart';

class GoalService {
  GoalService(this.client);

  final ApiClient client;

  /// Lists all goals with totals for the Savings screen.
  Future<GoalsResponseModel> getGoals({String? month}) async {
    final query = (month != null && month.isNotEmpty) ? '?month=$month' : '';
    final res = await client.get('/goals$query');
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return GoalsResponseModel.fromJson(data);
  }

  /// Creates a new savings goal via `POST /api/goals`.
  ///
  /// [targetAmountPaise] must be a whole number of paise (e.g. ₹20,000 -> 2,000,000).
  /// [targetMonth] must be formatted as 'YYYY-MM' (e.g. '2027-03').
  /// [icon] must be one of: 'shield', 'phone', 'plane', 'house', 'gift', 'star'.
  Future<void> createGoal({
    required String name,
    required String icon,
    required int targetAmountPaise,
    required String targetMonth,
  }) async {
    await client.post('/goals', {
      'name': name.trim(),
      'icon': icon,
      'targetAmount': targetAmountPaise,
      'targetMonth': targetMonth,
    });
  }

  /// Adds money or takes money out from a goal via `POST /api/goals/:id/contributions`.
  ///
  /// [amountPaise] > 0 puts money aside, < 0 takes money out.
  /// [date] and [today] must be 'YYYY-MM-DD'.
  Future<void> addContribution({
    required String goalId,
    required int amountPaise,
    required String date,
    required String today,
  }) async {
    await client.post('/goals/$goalId/contributions', {
      'amount': amountPaise,
      'date': date,
      'today': today,
    });
  }

  /// Deletes a savings goal via `DELETE /api/goals/:id`.
  Future<void> deleteGoal(String goalId) async {
    await client.delete('/goals/$goalId');
  }
}
