import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';

/// Centered compact HUD loader with an elegant square card
/// allowing the underlying screen to show through a translucent veil.
class CommonLoader extends StatelessWidget {
  const CommonLoader({
    super.key,
    this.backgroundColor = AppColors.surface,
    this.barrierColor,
    this.color = AppColors.popDeep,
    this.size = 32,
    this.strokeWidth = 3.0,
    this.width = 80,
    this.height = 80,
    this.borderRadius,
  });

  final Color backgroundColor;
  final Color? barrierColor;
  final Color color;
  final double size;
  final double strokeWidth;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppLayout.isTablet(context);
    final double boxWidth = isTablet ? width : width.r;
    final double boxHeight = isTablet ? height : height.r;
    final double effectiveSize = isTablet ? size : size.r;
    final double effectiveStroke = isTablet ? strokeWidth : strokeWidth.w;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: barrierColor ?? Colors.black.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              borderRadius ??
              (isTablet ? BorderRadius.circular(20) : AppBorderRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: isTablet ? 16 : 20.r,
              offset: Offset(0, isTablet ? 4 : 6.h),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.05),
              blurRadius: isTablet ? 8 : 10.r,
              offset: Offset(0, isTablet ? 2 : 2.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SizedBox.square(
          dimension: effectiveSize,
          child: CircularProgressIndicator(
            strokeWidth: effectiveStroke,
            color: color,
          ),
        ),
      ),
    );
  }
}
