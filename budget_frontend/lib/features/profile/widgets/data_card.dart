import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class DataCard extends StatelessWidget {
  final String name;
  final String count;
  final VoidCallback? onTap;

  const DataCard({
    super.key,
    required this.name,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AppCard(
          radius: AppBorderRadius.tile,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          isGradient: false,
          child: Column(
            children: [
              Text(
                count,
                style: AppTextStyle.title.copyWith(
                  fontSize: 30.sp,
                  height: 1,
                ),
              ),
              Text(
                name,
                style: AppTextStyle.toggleTitle.copyWith(
                  color: AppColors.muted,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
