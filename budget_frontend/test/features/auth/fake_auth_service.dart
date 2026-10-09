import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';

class FakeAuthService implements AuthService {
  bool verified = false;
  String? devCode = '123456';

  UserModel user(String email) => UserModel(email: email);

  @override
  Future<UserModel?> restoreSession() async => null;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    if (!verified) throw const ApiException('Email not verified', statusCode: 403);
    if (password != 'password123') {
      throw const ApiException('Invalid email or password', statusCode: 401);
    }
    return user(email);
  }

  @override
  Future<String?> signup({required String email, required String password}) async => devCode;

  @override
  Future<UserModel> verifyEmail({required String email, required String code}) async {
    if (code != devCode) throw const ApiException('Incorrect code', statusCode: 400);
    verified = true;
    return user(email);
  }

  @override
  Future<String?> resendVerificationCode(String email) async => devCode;

  @override
  Future<UserModel> googleSignIn() async => user('google@example.com');

  @override
  Future<String?> requestPasswordReset(String email) async => devCode;

  @override
  Future<void> verifyResetCode({required String email, required String code}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (code != devCode) throw const ApiException('Incorrect code', statusCode: 400);
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> logout() async {}
}
