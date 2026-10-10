import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/features/auth/bloc/auth_event.dart';
import 'package:budget_frontend/features/auth/bloc/auth_state.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';

export 'package:budget_frontend/features/auth/bloc/auth_event.dart';
export 'package:budget_frontend/features/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authService}) : super(const AuthState()) {
    on<AuthStarted>(onStarted);
    on<AuthLoginRequested>(onLoginRequested);
    on<AuthSignupRequested>(onSignupRequested);
    on<AuthVerifyEmailRequested>(onVerifyEmailRequested);
    on<AuthResendVerifyCodeRequested>(onResendVerifyCodeRequested);
    on<AuthGoogleSignInRequested>(onGoogleSignInRequested);
    on<AuthForgotPasswordRequested>(onForgotPasswordRequested);
    on<AuthResendResetCodeRequested>(onResendResetCodeRequested);
    on<AuthResetPasswordRequested>(onResetPasswordRequested);
    on<AuthUserUpdated>(onUserUpdated);
    on<AuthLogoutRequested>(onLogoutRequested);
    on<AuthErrorCleared>(onErrorCleared);
  }

  final AuthService authService;

  /// Runs [action] with the loading flag on and turns any failure into an error message.
  Future<void> run(
    Emitter<AuthState> emit,
    Future<void> Function() action, {
    bool isGoogle = false,
    AuthScreen? screen,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, isLoading: true, clearError: true));
    try {
      await action();
    } on ApiException catch (e) {
      emit(failure(e.message, isGoogle, screen: screen));
    } catch (e, stack) {
      debugPrint('AuthBloc error: $e\n$stack');
      emit(failure('Something went wrong. Please try again.', isGoogle, screen: screen));
    }
  }

  AuthState failure(String message, bool isGoogle, {AuthScreen? screen}) => state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: isGoogle ? null : message,
        errorSource: isGoogle ? null : screen,
        googleErrorMessage: isGoogle ? message : null,
        googleErrorSource: isGoogle ? screen : null,
      );

  AuthState authenticated(UserModel user) => state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        clearDemoCode: true,
      );

  AuthState verificationPending(String email, String? code) => state.copyWith(
        status: AuthStatus.verificationPending,
        pendingEmail: email,
        demoCode: code,
        clearDemoCode: code == null,
        isLoading: false,
      );

  Future<void> onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authService.restoreSession();
      emit(user == null
          ? state.copyWith(status: AuthStatus.unauthenticated)
          : authenticated(user));
    } catch (e, stack) {
      debugPrint('AuthBloc restoreSession error: $e\n$stack');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) =>
      run(emit, () async {
        try {
          final user = await authService.login(email: event.email, password: event.password);
          emit(authenticated(user));
        } on ApiException catch (e) {
          if (!e.needsVerification) rethrow;
          emit(verificationPending(event.email, await resendQuietly(event.email)));
        }
      }, screen: AuthScreen.login);

  /// Sends a fresh code to an unverified account; the earlier code is still valid if this is rate limited.
  Future<String?> resendQuietly(String email) async {
    try {
      return await authService.resendVerificationCode(email);
    } on ApiException {
      return null;
    }
  }

  Future<void> onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) =>
      run(emit, () async {
        final code = await authService.signup(email: event.email, password: event.password);
        emit(verificationPending(event.email, code));
      }, screen: AuthScreen.signup);

  Future<void> onVerifyEmailRequested(AuthVerifyEmailRequested event, Emitter<AuthState> emit) =>
      run(emit, () async {
        final user = await authService.verifyEmail(email: state.pendingEmail, code: event.code);
        emit(authenticated(user));
      }, screen: AuthScreen.verifyEmail);

  Future<void> onResendVerifyCodeRequested(
    AuthResendVerifyCodeRequested event,
    Emitter<AuthState> emit,
  ) =>
      run(emit, () async {
        final code = await authService.resendVerificationCode(state.pendingEmail);
        emit(verificationPending(state.pendingEmail, code));
      }, screen: AuthScreen.verifyEmail);

  Future<void> onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) =>
      run(emit, () async {
        emit(authenticated(await authService.googleSignIn(isSignup: event.isSignup)));
      }, isGoogle: true, screen: event.isSignup ? AuthScreen.signup : AuthScreen.login);

  Future<void> onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) =>
      run(emit, () async {
        final code = await authService.requestPasswordReset(event.email);
        emit(state.copyWith(
          status: AuthStatus.passwordResetSent,
          resetEmail: event.email,
          demoCode: code,
          clearDemoCode: code == null,
          isLoading: false,
        ));
      }, screen: AuthScreen.forgotPassword);

  void onResendResetCodeRequested(AuthResendResetCodeRequested event, Emitter<AuthState> emit) {
    if (state.resetEmail.isEmpty) return;
    add(AuthForgotPasswordRequested(email: state.resetEmail));
  }

  Future<void> onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) =>
      run(emit, () async {
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
      }, screen: AuthScreen.resetPassword);

  void onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) =>
      emit(state.copyWith(user: event.user));

  Future<void> onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
      clearSuccessMessage: true,
    ));
  }

  void onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state.errorMessage == null && state.googleErrorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }
}
