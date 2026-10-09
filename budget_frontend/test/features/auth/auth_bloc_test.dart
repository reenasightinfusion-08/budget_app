import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/services/mock_auth_service.dart';

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

  test('signup flow emits authenticated state', () async {
    final expectation = expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.authenticated &&
            state.user?.email == 'test@example.com' &&
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

    authBloc.add(const AuthGoogleSignInRequested());
    await expectation;
  });

  test('logout flow emits unauthenticated state', () async {
    authBloc.add(const AuthLogoutRequested());
    await expectLater(
      authBloc.stream,
      emitsThrough(
        predicate<AuthState>((state) => state.status == AuthStatus.unauthenticated && state.user == null),
      ),
    );
  });
}
