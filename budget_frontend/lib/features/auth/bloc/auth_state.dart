import 'package:flutter/foundation.dart';

import 'package:budget_frontend/features/auth/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  verificationPending,
  passwordResetSent,
  passwordResetSuccess,
}

enum AuthScreen {
  login,
  signup,
  forgotPassword,
  resetPassword,
  verifyEmail,
}

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.errorSource,
    this.googleErrorMessage,
    this.googleErrorSource,
    this.pendingEmail = '',
    this.resetEmail = '',
    this.demoCode,
    this.successMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final AuthScreen? errorSource;
  final String? googleErrorMessage;
  final AuthScreen? googleErrorSource;
  final String pendingEmail;
  final String resetEmail;
  final String? demoCode;
  final String? successMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
    AuthScreen? errorSource,
    String? googleErrorMessage,
    AuthScreen? googleErrorSource,
    bool clearError = false,
    String? pendingEmail,
    String? resetEmail,
    String? demoCode,
    bool clearDemoCode = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorSource: clearError ? null : (errorSource ?? this.errorSource),
      googleErrorMessage: clearError ? null : (googleErrorMessage ?? this.googleErrorMessage),
      googleErrorSource: clearError ? null : (googleErrorSource ?? this.googleErrorSource),
      pendingEmail: pendingEmail ?? this.pendingEmail,
      resetEmail: resetEmail ?? this.resetEmail,
      demoCode: clearDemoCode ? null : (demoCode ?? this.demoCode),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
