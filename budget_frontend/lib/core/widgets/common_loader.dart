import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// Centered card loader (70% width, 25% screen height) with surface background
/// allowing the underlying screen to show through a translucent veil.
class CommonLoader extends StatelessWidget {
  const CommonLoader({
    super.key,
    this.backgroundColor = AppColors.surface,
    this.barrierColor,
    this.color = AppColors.popDeep,
    this.size = 40,
    this.strokeWidth = 3.5,
  });

  final Color backgroundColor;
  final Color? barrierColor;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final double boxWidth = screenSize.width * 0.70;
    final double boxHeight = screenSize.height * 0.25;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: barrierColor ?? Colors.black.withValues(alpha: 0.20),
      alignment: Alignment.center,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppBorderRadius.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28.r,
              offset: Offset(0, 10.h),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SizedBox.square(
          dimension: size.r,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth.w,
            color: color,
          ),
        ),
      ),
    );
  }
}
