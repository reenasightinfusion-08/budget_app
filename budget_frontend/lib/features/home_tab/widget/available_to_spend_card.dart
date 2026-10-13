import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class AvailableToSpendCard extends StatelessWidget {
  const AvailableToSpendCard({super.key});

  String _getCurrentMonthLastDate() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    const months = [
      'Jan',
      'Feb',
      'March',
      'April',
      'May',
      'June',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthName = months[now.month - 1];
    return '$monthName $lastDay ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 18.h),
      width: double.infinity,
      child: AppCard(
        isGradient: true,
        radius: AppBorderRadius.card,
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.glassFill,
              foregroundColor: AppColors.onAccent,
              radius: 25.r,
              child: Icon(
                AppIcons.wallet,
                size: 25.sp,
              ),
            ),
            14.verticalSpace,
            Text(
              'Available to spend',
              style: AppTextStyle.title.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onAccent,
              ),
            ),
            8.verticalSpace,
            RichText(
              text: TextSpan(
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.onAccentMuted,
                ),
                children: [
                  TextSpan(
                    text: '${AppFormatters.rupees(15000)} ',
                    style: AppTextStyle.title.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onAccent,
                    ),
                  ),
                  const TextSpan(
                    text: 'left this month',
                  ),
                ],
              ),
            ),
            16.verticalSpace,
            Container(
              height: 8.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.onAccent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            12.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyle.chip.copyWith(
                      color: AppColors.onAccentMuted,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    text: '${AppFormatters.rupees(0)} / ${AppFormatters.rupees(15000)}',
                  ),
                ),
                Text(
                  _getCurrentMonthLastDate(),
                  style: AppTextStyle.chip.copyWith(
                    color: AppColors.onAccentMuted,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
