import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}

class FloatingBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<NavItemData> items;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.items = const [
      NavItemData(icon: AppIcons.home, label: 'Home'),
      NavItemData(icon: AppIcons.analytics, label: 'Insights'),
      NavItemData(icon: AppIcons.wallet, label: 'Wallet'),
      NavItemData(icon: AppIcons.savings, label: 'Savings'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic padding logic:
    // If the left-most item is expanded, left end padding is less (6.w).
    // Otherwise, left end padding is more (20.w).
    // If the right-most item is expanded, right end padding is less (6.w).
    // Otherwise, right end padding is more (20.w).
    final double leftPadding = selectedIndex == 0 ? 6.w : 20.w;
    final double rightPadding =
        selectedIndex == (items.length - 1) ? 6.w : 20.w;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 64.h,
      padding: EdgeInsets.only(
        left: leftPadding,
        right: rightPadding,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 24.r,
            spreadRadius: 0,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.04),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              //curve: Curves.easeInOut,
              curve: Curves.linear,
              padding: isSelected
                  ? EdgeInsets.only(left: 4.w, right: 16.w, top: 4.h, bottom: 4.h)
                  : EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.fill : Colors.transparent,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(9.r),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 8.r,
                            spreadRadius: 0,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        size: 22.sp,
                        color: AppColors.onAccent,
                      ),
                    )
                  else
                    Icon(
                      item.icon,
                      size: 24.sp,
                      color: AppColors.muted,
                    ),
                  if (isSelected) ...[
                    10.horizontalSpace,
                    Text(
                      item.label,
                      style: AppTextStyle.cardLabel.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
