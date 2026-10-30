import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Spend button: blue & white theme
        Expanded(
          child: _ActionCard(
            title: 'Spend',
            subtitle: 'Money out',
            icon: AppIcons.arrowUpRight,
            onTap: () =>
                SpendIncomeBottomSheet.show(context, initialTabIndex: 0),
          ),
        ),
        12.horizontalSpace,
        // Income button: blue & white theme
        Expanded(
          child: _ActionCard(
            title: 'Income',
            subtitle: 'Money in',
            icon: AppIcons.arrowDownLeft,
            onTap: () =>
                SpendIncomeBottomSheet.show(context, initialTabIndex: 1),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 13.w,
            vertical: isTablet ? 13 : 12.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.line.withValues(alpha: 0.9),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.035),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular icon badge with soft blue background & signature blue icon
              Container(
                width: isTablet ? 36 : 38.r,
                height: isTablet ? 36 : 38.r,
                decoration: const BoxDecoration(
                  color: AppColors.popSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  size: isTablet ? 18 : 19.sp,
                  color: AppColors.accent,
                ),
              ),
              isTablet ? const SizedBox(width: 10) : 10.horizontalSpace,
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyle.subCardTitle.copyWith(
                        fontSize: isTablet ? 15.5 : 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 2 : 2.h),
                    Text(
                      widget.subtitle,
                      style: AppTextStyle.description.copyWith(
                        fontSize: isTablet ? 12 : 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Subtle mini chevron indicator
              Icon(
                AppIcons.chevronRight,
                size: isTablet ? 15 : 15.sp,
                color: AppColors.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
