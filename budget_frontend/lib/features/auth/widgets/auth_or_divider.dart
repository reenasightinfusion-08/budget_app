import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'OR',
              style: AppTextStyle.fieldLabel.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
                letterSpacing: 1.sp,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.line, thickness: 1)),
        ],
      );
}
