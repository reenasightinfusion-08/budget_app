import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/surface_card.dart';

class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Insights', style: AppTextStyle.screenTitle),
        SurfaceCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          borderRadius: AppBorderRadius.pill,
          blur: 8,
          offsetY: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.calendar, size: 14.sp, color: AppColors.accent),
              7.horizontalSpace,
              Text(
                '${AppFormatters.monthShort(now.month)} ${now.year}',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
