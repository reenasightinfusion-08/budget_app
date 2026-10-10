import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/services/auth_service.dart';
import 'package:budget_frontend/features/home/screens/home_screen.dart';
import 'package:budget_frontend/features/home/screens/home_tab_screen.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';

class MockAuthService implements AuthService {
  @override
  Future<UserModel?> restoreSession() async => null;
  @override
  Future<UserModel> login({required String email, required String password}) async => UserModel(email: email);
  @override
  Future<String?> signup({required String email, required String password}) async => null;
  @override
  Future<UserModel> verifyEmail({required String email, required String code}) async => UserModel(email: email);
  @override
  Future<String?> resendVerificationCode(String email) async => null;
  @override
  Future<UserModel> googleSignIn({required bool isSignup}) async => const UserModel(email: 'google@example.com');
  @override
  Future<String?> requestPasswordReset(String email) async => null;
  @override
  Future<void> verifyResetCode({required String email, required String code}) async {}
  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {}
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> logout() async {}
}

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

    final apiClient = ApiClient();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(authService: MockAuthService())),
          BlocProvider<SetupBloc>(create: (_) => SetupBloc(profileService: ProfileService(apiClient))),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify FloatingBottomNavBar is visible
    expect(find.byType(FloatingBottomNavBar), findsOneWidget);

    // Verify HomeTabScreen is displayed
    expect(find.byType(HomeTabScreen), findsOneWidget);

    // Tap on Insights tab (index 1) by icon
    await tester.tap(find.byIcon(AppIcons.analytics));
    await tester.pumpAndSettle();

    // Verify Insights screen title is displayed
    expect(find.text('Track your spending and income trends over time.'), findsOneWidget);

    // Tap on Wallet tab (index 2) by icon
    await tester.tap(find.byIcon(AppIcons.wallet));
    await tester.pumpAndSettle();

    // Verify Wallet screen title is displayed
    expect(find.text('Wallet & Accounts'), findsOneWidget);

    // Tap back to Home tab (index 0) by icon
    await tester.tap(find.byIcon(AppIcons.home));
    await tester.pumpAndSettle();

    // Verify HomeTabScreen is visible again
    expect(find.byType(HomeTabScreen), findsOneWidget);
  });
}
