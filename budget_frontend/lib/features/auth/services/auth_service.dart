import 'package:budget_frontend/features/auth/models/user_model.dart';

abstract class AuthService {
  /// Returns the signed-in user for a saved token, or null when there is none.
  Future<UserModel?> restoreSession();

  Future<UserModel> login({required String email, required String password});

  /// Creates the account and emails a 6-digit code.
  ///
  /// Returns the code only when the server could not send email (demo mode).
  Future<String?> signup({required String email, required String password});

  Future<UserModel> verifyEmail({required String email, required String code});

  Future<String?> resendVerificationCode(String email);

  /// [isSignup] false means log in only: fails when no account exists for the Google email.
  Future<UserModel> googleSignIn({required bool isSignup});

  Future<String?> requestPasswordReset(String email);

  Future<void> verifyResetCode({required String email, required String code});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> changePassword({required String currentPassword, required String newPassword});

  Future<void> deleteAccount();

  Future<void> logout();
}
