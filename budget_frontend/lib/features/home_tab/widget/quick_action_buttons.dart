import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Spend button: bg surface, radius card, icon bg catShopping, icon color error
        Expanded(
          child: _ActionButton(
            label: 'Spend',
            icon: AppIcons.arrowUpRight,
            iconBgColor: AppColors.catShopping.withValues(alpha: 0.15),
            iconColor: AppColors.error,
            onTap: () => SpendIncomeBottomSheet.show(context, initialTabIndex: 0),
          ),
        ),
        12.horizontalSpace,
        // Income button: bg surface, radius card, icon bg catHealth, icon color success
        Expanded(
          child: _ActionButton(
            label: 'Income',
            icon: AppIcons.arrowDownLeft,
            iconBgColor: AppColors.catHealth.withValues(alpha: 0.15),
            iconColor: AppColors.success,
            onTap: () => SpendIncomeBottomSheet.show(context, initialTabIndex: 1),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        color: AppColors.surface,
        radius: AppBorderRadius.navBar,
        padding: isTablet
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
            : EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 32 : 36.w,
              height: isTablet ? 32 : 36.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppBorderRadius.track,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: isTablet ? 18 : 20.sp,
                color: iconColor,
              ),
            ),
            isTablet ? const SizedBox(width: 8) : 12.horizontalSpace,
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.subCardTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
