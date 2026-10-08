import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/providers/auth_provider.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key});

  @override
  Widget build(BuildContext context) {
    final message = context.select<AuthProvider, String?>((provider) => provider.errorMessage);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 18.h),
      child: Text(message ?? '', style: AppTextStyle.error),
    );
  }
}
