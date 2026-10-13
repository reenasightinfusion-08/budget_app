import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class DataRaw extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const DataRaw({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.card,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: iconBackgroundColor ?? AppColors.fill,
              foregroundColor: iconColor ?? AppColors.accent,
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? AppColors.accent,
              ),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.title.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  3.verticalSpace,
                  Text(
                    subtitle,
                    style: AppTextStyle.subtitle.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            Icon(
              AppIcons.chevronRight,
              color: AppColors.faint,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
