import 'package:flutter/foundation.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested({required this.email, required this.password});

  final String email;
  final String password;
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

final class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested({required this.email});

  final String email;
}

final class AuthResendResetCodeRequested extends AuthEvent {
  const AuthResendResetCodeRequested();
}

final class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({required this.code, required this.newPassword});

  final String code;
  final String newPassword;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
