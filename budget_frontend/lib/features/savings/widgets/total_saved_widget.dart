import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';

class TotalSavedWidget extends StatelessWidget {
  const TotalSavedWidget({
    super.key,
    this.totalSaved = 0,
    this.monthlyAdded = 0,
    this.targetTotal = 0,
    this.monthlyNeeded = 0,
    this.hasGoals = false,
  });

  final int totalSaved;
  final int monthlyAdded;
  final int targetTotal;
  final int monthlyNeeded;
  final bool hasGoals;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final double progressRatio = targetTotal > 0
        ? (totalSaved / targetTotal).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      width: double.infinity,
      isGradient: true,
      radius: AppBorderRadius.card,
      padding: isTablet ? const EdgeInsets.all(24) : EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total saved',
                style: AppTextStyle.cardLabel.copyWith(
                  fontSize: isTablet ? 14 : 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasGoals && targetTotal > 0)
                Container(
                  padding: isTablet
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                      : EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.pop,
                    borderRadius: AppBorderRadius.card,
                  ),
                  child: Text(
                    totalSaved >= targetTotal
                        ? 'Target reached! 🎉'
                        : 'Target: ${AppFormatters.rupees(targetTotal)}',
                    style: AppTextStyle.buttonPill.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 13 : null,
                    ),
                  ),
                ),
            ],
          ),
          isTablet ? const SizedBox(height: 6) : 5.verticalSpace,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹',
                  style: AppTextStyle.amountSymbol.copyWith(
                    fontSize: isTablet ? 26 : 35.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: AppFormatters.groupDigits(totalSaved),
                  style: AppTextStyle.amount.copyWith(
                    fontSize: isTablet ? 38 : 55.sp,
                  ),
                ),
              ],
            ),
          ),
          if (hasGoals) ...[
            isTablet ? const SizedBox(height: 12) : 12.verticalSpace,
            AppProgressBar(
              ratio: progressRatio,
              height: 8,
              color: AppColors.pop,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              borderRadius: AppBorderRadius.pill,
            ),
          ],
          isTablet ? const SizedBox(height: 14) : 14.verticalSpace,
          if (!hasGoals)
            Text(
              'Pick something you want, like an emergency fund or a new phone. Budgie works out how much to put aside each month.',
              style: AppTextStyle.subtitle.copyWith(
                fontSize: isTablet ? 14 : 14.sp,
              ),
            )
          else if (targetTotal > 0 && totalSaved >= targetTotal)
            Text(
              'All current goals reached! Great job!',
              style: AppTextStyle.cardTitleWhite.copyWith(fontSize: isTablet ? 14 : 14.sp),
            )
          else
            RichText(
              text: TextSpan(
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: isTablet ? 14 : 14.sp,
                ),
                children: [
                  const TextSpan(text: 'Your goals need about '),
                  TextSpan(
                    text: '₹${AppFormatters.groupDigits(monthlyNeeded)} a month',
                    style: AppTextStyle.cardTitleWhite.copyWith(
                      fontSize: isTablet ? 14 : 14.sp,
                    ),
                  ),
                  const TextSpan(
                    text: ". Add this month's income to see how much you can save.",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

typedef TotalSavedCard = TotalSavedWidget;
