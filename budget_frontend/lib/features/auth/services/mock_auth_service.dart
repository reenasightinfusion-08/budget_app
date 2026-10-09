import 'dart:math';

import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_exception.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';
import 'package:budget_frontend/features/auth/services/google_auth_service.dart';

/// In-memory [AuthService] that lets the auth screens work before the backend
/// has auth endpoints. Accounts disappear when the app restarts.
class MockAuthService implements AuthService {
  final Map<String, String> passwords = {};
  final Map<String, String> resetCodes = {};
  final Random random = Random();
  final GoogleAuthService googleAuth = GoogleAuthService();

  String normalize(String email) => email.trim().toLowerCase();

  Future<void> simulateLatency() => Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await simulateLatency();
    final key = normalize(email);
    if (!passwords.containsKey(key)) {
      throw const AuthException('No account with that email. Check it or create one.');
    }
    if (passwords[key] != password) {
      throw const AuthException('That password doesn’t match. Try again or reset it.');
    }
    return UserModel(email: key);
  }

  @override
  Future<UserModel> signup({required String email, required String password}) async {
    await simulateLatency();
    final key = normalize(email);
    if (passwords.containsKey(key)) {
      throw const AuthException('An account with this email already exists. Log in instead.');
    }
    passwords[key] = password;
    return UserModel(email: key);
  }

  @override
  Future<UserModel> googleSignIn() => googleAuth.signIn();

  @override
  Future<String?> requestPasswordReset(String email) async {
    await simulateLatency();
    final key = normalize(email);
    if (!passwords.containsKey(key)) {
      throw const AuthException('No account with that email. Check it or create one.');
    }
    final code = (100000 + random.nextInt(900000)).toString();
    resetCodes[key] = code;
    return code;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await simulateLatency();
    final key = normalize(email);
    if (resetCodes[key] != code) {
      throw const AuthException('That code doesn’t match. Use the code shown above.');
    }
    passwords[key] = newPassword;
    resetCodes.remove(key);
  }
}
