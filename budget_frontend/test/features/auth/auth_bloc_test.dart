import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';

class MockAuthService implements AuthService {
  @override
  Future<UserModel?> restoreSession() async => null;

  @override
  Future<UserModel> login({required String email, required String password}) async =>
      UserModel(email: email);

  @override
  Future<String?> signup({required String email, required String password}) async => null;

  @override
  Future<UserModel> verifyEmail({required String email, required String code}) async =>
      UserModel(email: email);

  @override
  Future<String?> resendVerificationCode(String email) async => null;

  @override
  Future<UserModel> googleSignIn({required bool isSignup}) async =>
      const UserModel(email: 'google@example.com');

  @override
  Future<String?> requestPasswordReset(String email) async => null;

  @override
  Future<void> verifyResetCode({required String email, required String code}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> logout() async {}
}

void main() {
  late MockAuthService service;
  late AuthBloc authBloc;

  setUp(() {
    service = MockAuthService();
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

  test('signup flow emits verificationPending state', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.verificationPending &&
            state.pendingEmail == 'test@example.com' &&
            !state.isLoading),
      ),
    );

    authBloc.add(const AuthSignupRequested(email: 'test@example.com', password: 'password123'));
    await expectation;
  });

  test('google sign in emits authenticated state', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.authenticated &&
            state.user?.email != null &&
            !state.isLoading),
      ),
    );

    authBloc.add(const AuthGoogleSignInRequested(isSignup: true));
    await expectation;
  });

  test('logout flow emits unauthenticated state', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) => state.status == AuthStatus.unauthenticated && state.user == null),
      ),
    );
    authBloc.add(const AuthLogoutRequested());
    await expectation;
  });
}
