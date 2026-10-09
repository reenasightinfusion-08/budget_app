import 'package:flutter/material.dart';

import 'package:budget_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:budget_frontend/features/auth/screens/login_screen.dart';
import 'package:budget_frontend/features/auth/screens/reset_password_screen.dart';
import 'package:budget_frontend/features/auth/screens/signup_screen.dart';
import 'package:budget_frontend/features/auth/screens/verify_email_screen.dart';
import 'package:budget_frontend/features/home/screens/home_screen.dart';
import 'package:budget_frontend/features/setup/screens/setup_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String setup = '/setup';
  static const String home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
    verifyEmail: (_) => const VerifyEmailScreen(),
    setup: (_) => const SetupScreen(),
    home: (_) => const HomeScreen(),
  };
}
