import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class TotalSavedWidget extends StatelessWidget {
  const TotalSavedWidget({
    super.key,
    this.totalSaved = 50200,
    this.monthlyAdded = 50200,
    this.targetTotal = 70000,
    this.monthlyNeeded = 1764,
  });

  final int totalSaved;
  final int monthlyAdded;
  final int targetTotal;
  final int monthlyNeeded;

  @override
  Widget build(BuildContext context) {
    final double progressRatio = targetTotal > 0
        ? (totalSaved / targetTotal).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      isGradient: true,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total saved',
                style: AppTextStyle.cardLabel.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.pop,
                  borderRadius: AppBorderRadius.card,
                ),
                child: Text(
                  '+${AppFormatters.rupees(monthlyAdded)} this month',
                  style: AppTextStyle.buttonPill.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          5.verticalSpace,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹',
                  style: AppTextStyle.amountSymbol.copyWith(
                    fontSize: 35.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: AppFormatters.groupDigits(totalSaved),
                  style: AppTextStyle.amount.copyWith(
                    fontSize: 55.sp,
                  ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
          // Progress Bar: Translucent track (total to save) & Pop color (already saved)
          Container(
            height: 8.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: AppBorderRadius.pill,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.pop,
                  borderRadius: AppBorderRadius.pill,
                ),
              ),
            ),
          ),
          14.verticalSpace,
          RichText(
            text: TextSpan(
              style: AppTextStyle.subtitle.copyWith(
                fontSize: 14.sp,
              ),
              children: [
                const TextSpan(text: 'Your goals need about '),
                TextSpan(
                  text: '₹${AppFormatters.groupDigits(monthlyNeeded)} a month',
                  style: AppTextStyle.cardTitleWhite.copyWith(
                    fontSize: 14.sp,
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
