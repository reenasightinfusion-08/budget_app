import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

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
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.popSoft,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: AppColors.ink,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(
                    text: 'Easy fix: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
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
