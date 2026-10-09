import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/app/app.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/features/auth/screens/signup_screen.dart';
import 'package:budget_frontend/features/auth/screens/verify_email_screen.dart';
import 'package:budget_frontend/features/setup/screens/setup_screen.dart';

void main() {
  testWidgets('Signup navigates to Verify Email screen and stays until code is verified', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Suppress overflow errors caused by font rendering in headless test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(const BudgetApp());
    await tester.pumpAndSettle();

    // Tap on "Create an account" AppLinkButton on Login screen
    final createAccountFinder = find.widgetWithText(AppLinkButton, 'Create an account');
    expect(createAccountFinder, findsOneWidget);
    await tester.tap(createAccountFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify we are on SignupScreen
    expect(find.byType(SignupScreen), findsOneWidget);

    // Enter email, password, and confirm password on SignupScreen
    await tester.enterText(find.widgetWithText(TextFormField, 'Email address'), 'user@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password (6+ characters)'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'password123');
    await tester.pumpAndSettle();

    // Tap "Create account" button
    final submitBtn = find.widgetWithText(AppButton, 'Create account');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify we navigated to VerifyEmailScreen
    expect(find.byType(VerifyEmailScreen), findsOneWidget);

    // Wait longer than mock auth service latency (600ms+)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that VerifyEmailScreen is STILL visible and hasn't automatically redirected
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.byType(SetupScreen), findsNothing);

    // Tap "Verify" button with incomplete code (< 6 digits)
    await tester.tap(find.widgetWithText(AppButton, 'Verify'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify error message is displayed and screen is still VerifyEmailScreen
    expect(find.text('Please enter the complete 6-digit verification code.'), findsOneWidget);
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.byType(SetupScreen), findsNothing);

    // Enter full 6-digit verification code into the hidden OTP text field
    final otpTextField = find.byType(TextField).first;
    await tester.enterText(otpTextField, '123456');
    await tester.pumpAndSettle();

    // Tap "Verify" button explicitly
    await tester.tap(find.widgetWithText(AppButton, 'Verify'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Now verify we have navigated to SetupScreen
    expect(find.byType(SetupScreen), findsOneWidget);
  });
}
