import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
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
    final Color progressColor =
        isCompleted ? AppColors.success : AppColors.accent;

    return SizedBox(
      width: size.r,
      height: size.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 4.w,
              strokeCap: StrokeCap.round,
              backgroundColor: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Icon(
            icon,
            size: 20.sp,
            color: AppColors.ink,
          ),
        ],
      ),
    );
  }
}

/// Goal display card with progress circle, details, and monthly saving target.
class GoalCardWidget extends StatelessWidget {
  const GoalCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoalDetailBottomSheet.show(context),
      child: AppCard(
        isGradient: false,
        radius: AppBorderRadius.card,
        padding: EdgeInsets.all(16.r),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Row containing circle, title/percentage, and amounts
          Row(
            children: [
              // i. Goal process circle (20% progress)
              const GoalProgressCircle(
                icon: Icons.laptop_mac_rounded,
                progress: 0.20,
              ),
              12.horizontalSpace,
              // ii. Column: 1st. Laptop, 2nd. 20% · by Apr 2027
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laptop',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    '20% · by Apr 2027',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // iii. Column: 1st. ₹53,200, 2nd. of ₹50,000
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹53,200',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    'of ₹50,000',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          14.verticalSpace,
          // 2. Container that shows monthly saving requirement
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: AppColors.muted,
                ),
                children: [
                  const TextSpan(text: 'Save '),
                  TextSpan(
                    text: '₹1,764 a month',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const TextSpan(text: ' to reach it by Apr 2027.'),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
