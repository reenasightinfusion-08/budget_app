import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/features/auth/providers/auth_provider.dart';
import 'package:budget_frontend/features/home/widgets/home_greeting.dart';

/// Placeholder landing screen so the auth flow has somewhere to go.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                24.verticalSpace,
                const HomeGreeting(),
                const Spacer(),
                AppButton(
                  label: 'Log out',
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
