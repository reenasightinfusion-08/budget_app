import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/savings/models/goal_model.dart';
import 'package:budget_frontend/features/savings/widgets/goal_detail_bottom_sheet.dart';

/// Circular progress ring surrounding an icon for goal tracking.
class GoalProgressCircle extends StatelessWidget {
  const GoalProgressCircle({
    super.key,
    required this.icon,
    required this.progress,
    this.size = 50,
  });

  final IconData icon;
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = progress >= 1.0;
    final Color progressColor = isCompleted
        ? AppColors.success
        : AppColors.accent;
    final bool isTablet = AppLayout.isTablet(context);

    return SizedBox(
      width: isTablet ? size : size.r,
      height: isTablet ? size : size.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: isTablet ? 4 : 4.w,
              strokeCap: StrokeCap.round,
              backgroundColor: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Icon(icon, size: isTablet ? 20 : 20.sp, color: AppColors.ink),
        ],
      ),
    );
  }
}

/// Goal display card with progress circle, details, and monthly saving target.
class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({super.key, required this.goal, this.onTap});

  final GoalModel goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTap: onTap ?? () => GoalDetailBottomSheet.show(context, goal: goal),
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        isGradient: false,
        radius: AppBorderRadius.card,
        padding: isTablet ? const EdgeInsets.all(16) : EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GoalProgressCircle(
                  icon: goal.iconData,
                  progress: goal.progressRatio,
                ),
                isTablet ? const SizedBox(width: 12) : 12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: AppTextStyle.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalSpace,
                      Text(
                        '${goal.progressPercent}% · by ${goal.formattedTargetMonth}',
                        style: AppTextStyle.subHeader,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.rupees(goal.savedAmountRupees),
                      style: AppTextStyle.cardTitle,
                    ),
                    2.verticalSpace,
                    Text(
                      'of ${AppFormatters.rupees(goal.targetAmountRupees)}',
                      style: AppTextStyle.subHeader,
                    ),
                  ],
                ),
              ],
            ),
            if (!goal.isReached && goal.monthlyNeededRupees > 0) ...[
              isTablet ? const SizedBox(height: 14) : 14.verticalSpace,
              AppCard(
                width: double.infinity,
                color: AppColors.fill,
                radius: AppBorderRadius.chip,
                padding: isTablet
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                    : EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyle.fieldLabel,
                    children: [
                      const TextSpan(text: 'Save '),
                      TextSpan(
                        text:
                            '${AppFormatters.rupees(goal.monthlyNeededRupees)} a month',
                        style: AppTextStyle.fieldLabel.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      TextSpan(
                        text: ' to reach it by ${goal.formattedTargetMonth}.',
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (goal.isReached) ...[
              isTablet ? const SizedBox(height: 14) : 14.verticalSpace,
              AppCard(
                width: double.infinity,
                color: AppColors.successSoft,
                radius: AppBorderRadius.chip,
                padding: isTablet
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                    : EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.checkCircle,
                      color: AppColors.success,
                      size: isTablet ? 18 : 18.sp,
                    ),
                    isTablet ? const SizedBox(width: 8) : 8.horizontalSpace,
                    Text(
                      'Goal reached! 🎉',
                      style: AppTextStyle.fieldLabel.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
