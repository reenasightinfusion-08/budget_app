import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';
import 'package:budget_frontend/features/auth/services/google_auth_service.dart';

class ApiAuthService implements AuthService {
  ApiAuthService(this.client);

  final ApiClient client;
  final GoogleAuthService googleAuth = GoogleAuthService();

  Future<UserModel> startSession(Map<String, dynamic> data) async {
    await client.saveToken(data['token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel?> restoreSession() async {
    await client.loadToken();
    if (client.token == null) return null;
    try {
      final data = await client.get('/users/me');
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.isUnauthorized) await client.clearToken();
      return null;
    }
  }

  @override
  Future<UserModel> login({required String email, required String password}) async =>
      startSession(await client.post('/auth/login', {'email': email, 'password': password}));

  @override
  Future<String?> signup({required String email, required String password}) async {
    final data = await client.post('/auth/signup', {'email': email, 'password': password});
    return data['devCode'] as String?;
  }

  @override
  Future<UserModel> verifyEmail({required String email, required String code}) async =>
      startSession(await client.post('/auth/verify-email', {'email': email, 'code': code}));

  @override
  Future<String?> resendVerificationCode(String email) async {
    final data = await client.post('/auth/resend-code', {'email': email});
    return data['devCode'] as String?;
  }

  @override
  Future<UserModel> googleSignIn({required bool isSignup}) async {
    final idToken = await googleAuth.fetchIdToken();
    return startSession(await client.post('/auth/google', {
      'idToken': idToken,
      'mode': isSignup ? 'signup' : 'login',
    }));
  }

  @override
  Future<String?> requestPasswordReset(String email) async {
    final data = await client.post('/auth/forgot-password', {'email': email});
    return data['devCode'] as String?;
  }

  @override
  Future<void> verifyResetCode({required String email, required String code}) =>
      client.post('/auth/verify-reset-code', {'email': email, 'code': code});

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      client.post('/auth/reset-password', {'email': email, 'code': code, 'newPassword': newPassword});

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      client.post('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  @override
  Future<void> deleteAccount() async {
    await client.delete('/users/me');
    await client.clearToken();
  }

  @override
  Future<void> logout() => client.clearToken();
}
