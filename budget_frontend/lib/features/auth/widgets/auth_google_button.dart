import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.pill,
            border: Border.all(color: AppColors.line, width: 1.5.w),
          ),
          child: InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onPressed();
            },
            borderRadius: AppBorderRadius.pill,
            child: Container(
              height: 52.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assest/googlelogo2.png',
                    width: 22.r,
                    height: 22.r,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28.r,
                      color: AppColors.ink,
                    ),
                  ),
                  10.horizontalSpace,
                  Text(
                    label,
                    style: AppTextStyle.button.copyWith(
                      fontSize: 15.sp,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
