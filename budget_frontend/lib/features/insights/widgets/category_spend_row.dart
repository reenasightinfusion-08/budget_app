import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';
import 'package:budget_frontend/core/widgets/category_icon_badge.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';

/// Category spend row: tinted icon, name, bar sized relative to [maxAmount], amount and share.
class CategorySpendRow extends StatelessWidget {
  const CategorySpendRow({
    super.key,
    required this.spend,
    required this.maxAmount,
    this.showDivider = true,
  });

  final CategorySpend spend;
  final int maxAmount;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              CategoryIconBadge(
                icon: spend.icon,
                size: 42,
                iconColor: spend.color,
                backgroundColor: spend.color.withValues(alpha: 0.12),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(spend.name, style: AppTextStyle.toggleTitle),
                    8.verticalSpace,
                    AppProgressBar(
                      ratio: maxAmount > 0 ? (spend.amount / maxAmount).clamp(0.0, 1.0) : 0.0,
                      height: 7,
                      color: spend.color,
                    ),
                  ],
                ),
              ),
              14.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.rupees(spend.amount),
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    '${spend.percentageInt}%',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1.h, thickness: 1.h, color: AppColors.line),
      ],
    );
  }
}
