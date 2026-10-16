import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';

class ProfileService {
  ProfileService(this.client);

  final ApiClient client;

  Future<UserModel> saveSetup({required String name, required int monthlyBudgetPaise}) async {
    final data = await client.patch('/users/me', {'name': name, 'monthlyBudget': monthlyBudgetPaise});
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final data = await client.get('/users/me');
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateMonthlyBudget(int monthlyBudgetPaise) async {
    final data = await client.patch('/users/me', {'monthlyBudget': monthlyBudgetPaise});
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateCategoryLimits(Map<String, int> categoryLimitsPaise) async {
    final data = await client.patch('/users/me', {'categoryLimits': categoryLimitsPaise});
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
