import 'package:budget_frontend/features/auth/models/user_model.dart';

abstract class AuthService {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> signup({required String email, required String password});

  /// Starts a password reset for [email].
  ///
  /// Returns the code only when the service runs in demo mode and cannot send
  /// email; a real backend delivers the code by email and returns null.
  Future<String?> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
