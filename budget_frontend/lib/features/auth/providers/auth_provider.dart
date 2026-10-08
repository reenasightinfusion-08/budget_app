import 'package:flutter/foundation.dart';

import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_exception.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.authService});

  final AuthService authService;

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;
  String resetEmail = '';
  String? demoCode;

  /// Runs [action] with a shared loading flag and turns failures into
  /// [errorMessage], so every auth screen reports errors the same way.
  /// Returns false when the action failed.
  Future<bool> runGuarded(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e, stack) {
      debugPrint('AuthProvider error: $e\n$stack');
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) => runGuarded(() async {
        user = await authService.login(email: email, password: password);
      });

  Future<bool> signup({required String email, required String password}) => runGuarded(() async {
        user = await authService.signup(email: email, password: password);
      });

  /// Remembers [email] so the reset screen can finish the flow the user started
  /// on the forgot-password screen.
  Future<bool> requestPasswordReset(String email) => runGuarded(() async {
        demoCode = await authService.requestPasswordReset(email);
        resetEmail = email;
      });

  Future<bool> resendResetCode() => requestPasswordReset(resetEmail);

  Future<bool> resetPassword({required String code, required String newPassword}) =>
      runGuarded(() async {
        await authService.resetPassword(email: resetEmail, code: code, newPassword: newPassword);
        resetEmail = '';
        demoCode = null;
      });

  void logout() {
    user = null;
    notifyListeners();
  }

  /// Clears a stale error so it doesn’t follow the user onto the next screen.
  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }
}
