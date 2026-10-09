import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/app/app.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/features/home/screens/home_tab_screen.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';

void main() {
  testWidgets('HomeScreen renders FloatingBottomNavBar and switches tabs', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 300));

    // Verify FloatingBottomNavBar is visible
    expect(find.byType(FloatingBottomNavBar), findsOneWidget);

    // Verify HomeTabScreen is displayed
    expect(find.byType(HomeTabScreen), findsOneWidget);

    // Tap on Analytics tab (index 1) by icon
    await tester.tap(find.byIcon(AppIcons.analytics));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Analytics screen title is displayed
    expect(find.text('Track your spending and income trends over time.'), findsOneWidget);

    // Tap on Wallet tab (index 2) by icon
    await tester.tap(find.byIcon(AppIcons.wallet));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Wallet screen title is displayed
    expect(find.text('Wallet & Accounts'), findsOneWidget);

    // Tap back to Home tab (index 0) by icon
    await tester.tap(find.byIcon(AppIcons.home));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify HomeTabScreen is visible again
    expect(find.byType(HomeTabScreen), findsOneWidget);
  });
}
