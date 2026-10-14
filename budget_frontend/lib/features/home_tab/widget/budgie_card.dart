import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';

class BudgieCard extends StatelessWidget {
  const BudgieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First child: AspectRatio 1 with pop background color
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: AppCard(
                color: AppColors.fill,
                radius: AppBorderRadius.card,
                child: Center(
                  child: Text(
                    '🦜',
                    style: TextStyle(fontSize: 32.sp),
                  ),
                ),
              ),
            ),
          ),
          10.horizontalSpace,

          // Second child: Column
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                5.verticalSpace,
                // 1. Row: "Budgie" text + AppCard with catHealth color and "Feeling great" (success color)
                Row(
                  children: [
                    Text(
                      'Budgie',
                      style: AppTextStyle.cardTitle,
                    ),
                    8.horizontalSpace,
                    AppCard(
                      color: AppColors.catHealth.withValues(alpha: 0.15),
                      radius: AppBorderRadius.pill,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      child: Text(
                        'Feeling great',
                        style: AppTextStyle.tag.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.catHealth,
                        ),
                      ),
                    ),
                  ],
                ),
                5.verticalSpace,

                // 2. Text: "chirp chirp! You're spending well under plce. I feel fantastic."
                Text(
                  "Chirp chirp! You're spending well under plce. I feel fantastic.",
                  style: AppTextStyle.body.copyWith(
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
                7.verticalSpace,

                // 3. Row: "Energy" + AppProgressBar + "100"
                Row(
                  children: [
                    Text(
                      'Energy',
                      style: AppTextStyle.description.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: AppProgressBar(
                        ratio: 1.0,
                        height: 7,
                        color: AppColors.popDeep,
                      ),
                    ),
                    8.horizontalSpace,
                    Text(
                      '100',
                      style: AppTextStyle.fieldLabel.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                5.verticalSpace
              ],
            ),
          ),
        ],
      ),
    );
  }
}
