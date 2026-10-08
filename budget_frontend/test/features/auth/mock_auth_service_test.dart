import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/features/auth/services/auth_exception.dart';
import 'package:budget_frontend/features/auth/services/mock_auth_service.dart';

void main() {
  late MockAuthService service;

  setUp(() => service = MockAuthService());

  test('signup then login succeeds', () async {
    await service.signup(email: 'A@b.com', password: 'secret1');
    final user = await service.login(email: 'a@b.com', password: 'secret1');
    expect(user.email, 'a@b.com');
  });

  test('login with wrong password throws', () async {
    await service.signup(email: 'a@b.com', password: 'secret1');
    expect(
      service.login(email: 'a@b.com', password: 'nope'),
      throwsA(isA<AuthException>()),
    );
  });

  test('reset flow changes the password', () async {
    await service.signup(email: 'a@b.com', password: 'secret1');
    final code = await service.requestPasswordReset('a@b.com');
    await service.resetPassword(email: 'a@b.com', code: code!, newPassword: 'newpass1');
    final user = await service.login(email: 'a@b.com', password: 'newpass1');
    expect(user.email, 'a@b.com');
  });

  test('reset with wrong code throws', () async {
    await service.signup(email: 'a@b.com', password: 'secret1');
    await service.requestPasswordReset('a@b.com');
    expect(
      service.resetPassword(email: 'a@b.com', code: '000000', newPassword: 'newpass1'),
      throwsA(isA<AuthException>()),
    );
  });
}
