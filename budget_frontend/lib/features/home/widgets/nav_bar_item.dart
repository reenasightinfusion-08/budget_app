import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';

/// One slot of [FloatingBottomNavBar]. [proximity] is 1 when the sliding pill
/// is exactly on this slot and 0 when it is a whole slot or more away, so the
/// colour follows the pill while it is dragged or springing.
class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.data,
    required this.proximity,
    required this.onTap,
  });

  final NavItemData data;
  final double proximity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(AppColors.muted, AppColors.accent, proximity)!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 1 + 0.18 * proximity,
            child: Icon(data.icon, size: 22.sp, color: color),
          ),
          2.verticalSpace,
          Text(
            data.label,
            maxLines: 1,
            softWrap: false,
            style: AppTextStyle.cardLabel.copyWith(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
