import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// White surface with a hairline border and soft shadow, shared by cards, tiles and round buttons.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
    this.blur = 16,
    this.offsetY = 4,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final double? width;
  final double? height;
  final double blur;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius ?? AppBorderRadius.card,
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: blur.r,
            offset: Offset(0, offsetY.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
