import 'package:flutter/material.dart';

import 'package:budget_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:budget_frontend/features/auth/screens/login_screen.dart';
import 'package:budget_frontend/features/auth/screens/reset_password_screen.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/auth/screens/signup_screen.dart';
import 'package:budget_frontend/features/auth/screens/splash_screen.dart';
import 'package:budget_frontend/features/auth/screens/verify_email_screen.dart';
import 'package:budget_frontend/features/history/screen/history_screen.dart';
import 'package:budget_frontend/features/home/screens/home_screen.dart';
import 'package:budget_frontend/features/profile/screens/profile_screen.dart';
import 'package:budget_frontend/features/savings/screen/savings_screen.dart';
import 'package:budget_frontend/features/setup/screens/setup_screen.dart';

import 'package:budget_frontend/features/wallet/screens/wallet_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String savings = '/savings';
  static const String budget = '/budget';

  static String afterAuth(UserModel? user) =>
      (user?.onboardingComplete ?? false) ? home : setup;

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
    verifyEmail: (_) => const VerifyEmailScreen(),
    setup: (_) => const SetupScreen(),
    home: (_) => const HomeScreen(),
    profile: (_) => const ProfileScreen(),
    history: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final initialFilterIndex = args is int ? args : 0;
      return HistoryScreen(initialFilterIndex: initialFilterIndex);
    },
    savings: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final showBackButton = args is Map
          ? (args['showBackButton'] ?? true)
          : (args is bool ? args : true);
      return SavingsScreen(showBackButton: showBackButton);
    },
    budget: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final showBackButton = args is Map
          ? (args['showBackButton'] ?? true)
          : (args is bool ? args : true);
      return WalletScreen(showBackButton: showBackButton);
    },
  };
}
