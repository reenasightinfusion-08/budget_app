import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/features/auth/bloc/auth_event.dart';
import 'package:budget_frontend/features/auth/bloc/auth_state.dart';
import 'package:budget_frontend/features/auth/services/auth_exception.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';

export 'package:budget_frontend/features/auth/bloc/auth_event.dart';
export 'package:budget_frontend/features/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService}) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResendResetCodeRequested>(_onResendResetCodeRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final AuthService authService;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await authService.login(email: event.email, password: event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
        isLoading: false,
      ));
    } catch (e, stack) {
      debugPrint('AuthBloc login error: $e\n$stack');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await authService.signup(email: event.email, password: event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
        isLoading: false,
      ));
    } catch (e, stack) {
      debugPrint('AuthBloc signup error: $e\n$stack');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await authService.googleSignIn();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        googleErrorMessage: e.message,
        isLoading: false,
      ));
    } catch (e, stack) {
      debugPrint('AuthBloc googleSignIn error: $e\n$stack');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        googleErrorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      ));
    }
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final demoCode = await authService.requestPasswordReset(event.email);
      emit(state.copyWith(
        status: AuthStatus.passwordResetSent,
        resetEmail: event.email,
        demoCode: demoCode,
        isLoading: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        isLoading: false,
      ));
    } catch (e, stack) {
      debugPrint('AuthBloc forgotPassword error: $e\n$stack');
      emit(state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      ));
    }
  }

  Future<void> _onResendResetCodeRequested(
    AuthResendResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.resetEmail.isEmpty) return;
    add(AuthForgotPasswordRequested(email: state.resetEmail));
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await authService.resetPassword(
        email: state.resetEmail,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        resetEmail: '',
        clearDemoCode: true,
        successMessage: 'Password updated. Log in with your new password.',
        isLoading: false,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        isLoading: false,
      ));
    } catch (e, stack) {
      debugPrint('AuthBloc resetPassword error: $e\n$stack');
      emit(state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      ));
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      clearError: true,
      clearSuccessMessage: true,
    ));
  }

  void _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    if (state.errorMessage == null && state.googleErrorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }
}
