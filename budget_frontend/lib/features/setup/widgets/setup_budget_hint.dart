import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_controllers.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class SetupBudgetHint extends StatelessWidget {
  const SetupBudgetHint({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: setupController,
        builder: (context, _) => buildHint(setupController.dailyAllowanceLabel),
      );

  Widget buildHint(String? dailyLabel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: AppBorderRadius.pill,
        border: Border.all(color: AppColors.glassBorder, width: 1.w),
      ),
      child: Text.rich(
        TextSpan(
          style: AppTextStyle.cardHint,
          children: [
            if (dailyLabel == null) const TextSpan(text: 'Pick a number you can stick to.'),
            if (dailyLabel != null) ...[
              const TextSpan(text: 'That’s about '),
              TextSpan(
                text: dailyLabel,
                style: AppTextStyle.cardHint.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
