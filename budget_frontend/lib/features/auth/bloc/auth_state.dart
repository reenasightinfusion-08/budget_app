import 'package:flutter/foundation.dart';

import 'package:budget_frontend/features/auth/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, passwordResetSent, passwordResetSuccess }

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.googleErrorMessage,
    this.resetEmail = '',
    this.demoCode,
    this.successMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final String? googleErrorMessage;
  final String resetEmail;
  final String? demoCode;
  final String? successMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    String? googleErrorMessage,
    bool clearError = false,
    String? resetEmail,
    String? demoCode,
    bool clearDemoCode = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      googleErrorMessage: clearError ? null : (googleErrorMessage ?? this.googleErrorMessage),
      resetEmail: resetEmail ?? this.resetEmail,
      demoCode: clearDemoCode ? null : (demoCode ?? this.demoCode),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
