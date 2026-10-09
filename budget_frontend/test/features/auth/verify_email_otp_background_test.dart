import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/app/app.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/features/auth/screens/signup_screen.dart';
import 'package:budget_frontend/features/auth/screens/verify_email_screen.dart';

void main() {
  testWidgets('Verify Email OTP containers swap background color for focused and filled boxes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(const BudgetApp());
    await tester.pumpAndSettle();

    // Navigate to Signup screen
    await tester.tap(find.widgetWithText(AppLinkButton, 'Create an account'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Enter signup details
    await tester.enterText(find.widgetWithText(TextFormField, 'Email address'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password (6+ characters)'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'password123');
    await tester.pumpAndSettle();

    // Tap "Create account" to navigate to VerifyEmailScreen
    await tester.tap(find.widgetWithText(AppButton, 'Create account'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailScreen), findsOneWidget);

    // Focus the OTP field
    final otpTextField = find.byType(TextField).first;
    tester.widget<TextField>(otpTextField).focusNode?.requestFocus();
    await tester.pumpAndSettle();

    // Helper to get decoration of index-th OTP container box (out of 6)
    BoxDecoration getBoxDecoration(int index) {
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(VerifyEmailScreen),
          matching: find.byType(Container),
        ),
      ).where((c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).border != null).toList();

      return containers[index].decoration as BoxDecoration;
    }

    // 1. Initially focus is on box 0 (empty)
    // Box 0 (focused): AppColors.surface
    // Boxes 1-5 (unfocused empty): AppColors.fill
    expect(getBoxDecoration(0).color, AppColors.surface);
    expect(getBoxDecoration(1).color, AppColors.fill);

    // 2. Enter 1 digit '5'
    await tester.enterText(otpTextField, '5');
    await tester.pumpAndSettle();


    // Box 0 is now filled and unfocused: AppColors.fill
    // Box 1 is now focused: AppColors.surface
    // Boxes 2-5 are unfocused empty: AppColors.fill
    expect(getBoxDecoration(0).color, AppColors.fill);
    expect(getBoxDecoration(1).color, AppColors.surface);
    expect(getBoxDecoration(2).color, AppColors.fill);

    // 3. Enter more digits '543' (total length 4)
    await tester.enterText(otpTextField, '5432');
    await tester.pumpAndSettle();

    // Boxes 0, 1, 2, 3 are filled and unfocused: AppColors.fill
    // Box 4 is focused: AppColors.surface
    // Box 5 is unfocused: AppColors.fill
    expect(getBoxDecoration(0).color, AppColors.fill);
    expect(getBoxDecoration(1).color, AppColors.fill);
    expect(getBoxDecoration(2).color, AppColors.fill);
    expect(getBoxDecoration(3).color, AppColors.fill);
    expect(getBoxDecoration(4).color, AppColors.surface);
    expect(getBoxDecoration(5).color, AppColors.fill);
  });
}
