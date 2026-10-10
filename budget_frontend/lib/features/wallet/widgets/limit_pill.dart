import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

/// Tappable "spent / limit" chip.
class LimitPill extends StatelessWidget {
  const LimitPill({super.key, required this.spent, required this.limit, required this.onTap});

  final int spent;
  final int limit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppFormatters.compactRupees(spent)} / ',
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
            Text(
              AppFormatters.rupees(limit),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
