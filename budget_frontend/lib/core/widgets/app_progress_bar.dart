import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.ratio,
    required this.height,
    this.color,
    this.gradient,
    this.backgroundColor,
    this.borderRadius,
  });

  final double ratio;
  final double height;
  final Color? color;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppBorderRadius.bar;

    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.fill,
        borderRadius: effectiveRadius,
      ),
      alignment: Alignment.centerLeft,
      child: ratio <= 0
          ? const SizedBox.shrink()
          : FractionallySizedBox(
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  gradient: gradient,
                  borderRadius: effectiveRadius,
                ),
              ),
            ),
    );
  }
}
