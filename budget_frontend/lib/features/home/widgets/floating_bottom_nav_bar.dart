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
      NavItemData(icon: AppIcons.analytics, label: 'Analytics'),
      NavItemData(icon: AppIcons.wallet, label: 'Wallet'),
      NavItemData(icon: AppIcons.person, label: 'Profile'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36.r),
      //  border: Border.all(color: AppColors.line.withOpacity(0.6), width: 1.w),
        border: Border.all(color: AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.08),
            blurRadius: 24.r,
            spreadRadius: 0,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.04),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: isSelected
                  ? EdgeInsets.only(left: 5.w, right: 16.w, top: 4.h, bottom: 4.h)
                  : EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
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
                            color: AppColors.accent.withOpacity(0.35),
                            blurRadius: 8.r,
                            spreadRadius: 0,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        size: 20.sp,
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
