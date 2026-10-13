import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: CircleAvatar(
            radius: 23.r,
            backgroundColor: AppColors.surface,
            child: Icon(
              AppIcons.chevronLeft,
              color: AppColors.ink,
              size: 25.sp,
            ),
          ),
        ),
        15.horizontalSpace,
        Text(
          'Profile',
          style: AppTextStyle.screenTitle
        ),
      ],
    );
  }
}
