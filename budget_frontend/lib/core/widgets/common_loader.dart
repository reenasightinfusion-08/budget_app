import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';

/// Centered card loader with a fixed, elegant width and height
/// allowing the underlying screen to show through a translucent veil.
class CommonLoader extends StatelessWidget {
  const CommonLoader({
    super.key,
    this.backgroundColor = AppColors.surface,
    this.barrierColor,
    this.color = AppColors.popDeep,
    this.size = 40,
    this.strokeWidth = 3.5,
    this.width = 240,
    this.height = 170,
  });

  final Color backgroundColor;
  final Color? barrierColor;
  final Color color;
  final double size;
  final double strokeWidth;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppLayout.isTablet(context);
    final double boxWidth = isTablet ? width : width.w;
    final double boxHeight = isTablet ? height : height.h;
    final double effectiveSize = isTablet ? size : size.r;
    final double effectiveStroke = isTablet ? strokeWidth : strokeWidth.w;

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
              blurRadius: isTablet ? 24 : 28.r,
              offset: Offset(0, isTablet ? 8 : 10.h),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: isTablet ? 10 : 12.r,
              offset: Offset(0, isTablet ? 4 : 4.h),
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
