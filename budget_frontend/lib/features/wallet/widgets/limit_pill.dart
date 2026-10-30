import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

/// Tappable "spent / limit" chip.
class LimitPill extends StatelessWidget {
  const LimitPill({
    super.key,
    required this.spent,
    required this.limit,
    required this.onTap,
  });

  final int spent;
  final int limit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        color: AppColors.fill,
        radius: AppBorderRadius.chip,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppFormatters.compactRupees(spent)} / ',
              style: AppTextStyle.description.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(AppFormatters.rupees(limit), style: AppTextStyle.chip),
          ],
        ),
      ),
    );
  }
}
