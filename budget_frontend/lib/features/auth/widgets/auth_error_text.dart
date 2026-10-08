import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_controllers.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: authController,
        builder: (context, _) => ConstrainedBox(
          constraints: BoxConstraints(minHeight: 18.h),
          child: Text(authController.errorMessage ?? '', style: AppTextStyle.error),
        ),
      );
}
