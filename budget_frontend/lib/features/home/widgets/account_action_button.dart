import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class AccountActionButton extends StatelessWidget {
  const AccountActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.error,
    this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: backgroundColor,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(
          label,
          style: AppTextStyle.fieldLabel.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
