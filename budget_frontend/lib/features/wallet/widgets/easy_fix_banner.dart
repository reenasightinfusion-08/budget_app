import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class EasyFixBanner extends StatelessWidget {
  const EasyFixBanner({
    super.key,
    required this.amount,
    required this.fromCategory,
    required this.toCategory,
    required this.onMove,
  });

  final int amount;
  final String fromCategory;
  final String toCategory;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 14.w, 12.h),
      color: AppColors.popSoft,
      radius: AppBorderRadius.dialog,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyle.body.copyWith(
                  color: AppColors.ink,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: 'Easy fix: ',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.ink,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'move ${AppFormatters.rupees(amount)} from $fromCategory to cover $toCategory.',
                  ),
                ],
              ),
            ),
          ),
          12.horizontalSpace,
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: AppBorderRadius.pill,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.pill,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              onPressed: onMove,
              child: Text(
                'Move it',
                style: AppTextStyle.buttonPill.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
