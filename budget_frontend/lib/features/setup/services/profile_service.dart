import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';

class ProfileService {
  ProfileService(this.client);

  final ApiClient client;

  Future<UserModel> saveSetup({required String name, required int monthlyBudgetPaise}) async {
    final data = await client.patch('/users/me', {'name': name, 'monthlyBudget': monthlyBudgetPaise});
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
