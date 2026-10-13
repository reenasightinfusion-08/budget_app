import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.border,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
    this.blur,
    this.offsetY,
    required this.child,
    this.isGradient = false,
    this.radius,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;
  final double? blur;
  final double? offsetY;
  final Widget child;
  final bool isGradient;
  final BorderRadiusGeometry? radius;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = shape == BoxShape.circle
        ? null
        : (radius ?? AppBorderRadius.card);

    final effectiveShadows = boxShadow ??
        (blur != null || offsetY != null
            ? [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: (blur ?? 16).r,
                  offset: Offset(0, (offsetY ?? 4).h),
                ),
              ]
            : null);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: effectiveRadius,
        border: border,
        boxShadow: effectiveShadows,
        color: color ?? (isGradient ? null : AppColors.surface),
        gradient: (color == null && isGradient) ? AppGradients.card : null,
      ),
      child: child,
    );
  }
}
