import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Shows the reset code on screen while the app runs without an email backend.
/// Renders nothing once a real service delivers the code by email.
class AuthDemoCodeBanner extends StatelessWidget {
  const AuthDemoCodeBanner({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final code = state.demoCode;
          if (code == null) return const SizedBox.shrink();

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: AppBorderRadius.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo mode. No email is sent yet, so your code is shown here.',
                  style: AppTextStyle.body.copyWith(color: AppColors.ink),
                ),
                4.verticalSpace,
                Text(code, style: AppTextStyle.code),
              ],
            ),
          );
        },
      );
}
