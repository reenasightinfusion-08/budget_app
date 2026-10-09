import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'fake_auth_service.dart';

void main() {
  late FakeAuthService service;
  late AuthBloc authBloc;

  setUp(() {
    service = FakeAuthService();
    authBloc = AuthBloc(authService: service);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is correct', () {
    expect(authBloc.state.status, AuthStatus.initial);
    expect(authBloc.state.user, isNull);
    expect(authBloc.state.isLoading, false);
  });

  test('signup asks for email verification and keeps the demo code', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.verificationPending &&
            state.pendingEmail == 'test@example.com' &&
            state.demoCode == '123456' &&
            !state.isLoading),
      ),
    );

    authBloc.add(const AuthSignupRequested(email: 'test@example.com', password: 'password123'));
    await expectation;
  });

  test('verifying the code authenticates the user', () async {
    authBloc.add(const AuthSignupRequested(email: 'test@example.com', password: 'password123'));
    await authBloc.stream.firstWhere((state) => state.status == AuthStatus.verificationPending);

    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.authenticated && state.user?.email == 'test@example.com'),
      ),
    );

    authBloc.add(const AuthVerifyEmailRequested(code: '123456'));
    await expectation;
  });

  test('wrong verification code shows the server message', () async {
    authBloc.add(const AuthSignupRequested(email: 'test@example.com', password: 'password123'));
    await authBloc.stream.firstWhere((state) => state.status == AuthStatus.verificationPending);

    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(predicate<AuthState>((state) => state.errorMessage == 'Incorrect code')),
    );

    authBloc.add(const AuthVerifyEmailRequested(code: '000000'));
    await expectation;
  });

  test('logging in with an unverified email goes to verification', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.verificationPending &&
            state.pendingEmail == 'test@example.com'),
      ),
    );

    authBloc.add(const AuthLoginRequested(email: 'test@example.com', password: 'password123'));
    await expectation;
  });

  test('login with a wrong password shows the error', () async {
    service.verified = true;
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) => state.errorMessage == 'Invalid email or password'),
      ),
    );

    authBloc.add(const AuthLoginRequested(email: 'test@example.com', password: 'wrongpass1'));
    await expectation;
  });

  test('google sign in emits authenticated state', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.authenticated && state.user?.email == 'google@example.com'),
      ),
    );

    authBloc.add(const AuthGoogleSignInRequested());
    await expectation;
  });

  test('password reset flow ends in success', () async {
    authBloc.add(const AuthForgotPasswordRequested(email: 'test@example.com'));
    await authBloc.stream.firstWhere((state) => state.status == AuthStatus.passwordResetSent);

    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(predicate<AuthState>((state) => state.status == AuthStatus.passwordResetSuccess)),
    );

    authBloc.add(const AuthResetPasswordRequested(code: '123456', newPassword: 'newpassword1'));
    await expectation;
  });

  test('logout clears the user', () async {
    authBloc.add(const AuthGoogleSignInRequested());
    await authBloc.stream.firstWhere((state) => state.status == AuthStatus.authenticated);

    authBloc.add(const AuthLogoutRequested());
    final state = await authBloc.stream.firstWhere((state) => state.status == AuthStatus.unauthenticated);
    expect(state.user, isNull);
  });
}
