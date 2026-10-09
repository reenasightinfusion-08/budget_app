import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// Reusable container widget supporting custom colors, border radius, padding,
/// dimensions, and a double-border focus effect when [isFocused] is true.
class CommonContainer extends StatelessWidget {
  const CommonContainer({
    super.key,
    this.child,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.focusedOutlineColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.isFocused = false,
    this.borderWidth = 1.0,
    this.focusedOutlineSpread = 3.0,
    this.boxShadow,
  });

  final Widget? child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? focusedOutlineColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final bool isFocused;
  final double borderWidth;
  final double focusedOutlineSpread;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppBorderRadius.md;
    final effectiveBorderColor = isFocused
        ? (focusedBorderColor ?? borderColor ?? AppColors.accent)
        : (borderColor ?? AppColors.line);

    final effectiveOutlineColor = focusedOutlineColor ?? AppColors.fill;

    final effectiveShadows = <BoxShadow>[
      if (isFocused)
        BoxShadow(
          color: effectiveOutlineColor,
          spreadRadius: focusedOutlineSpread,
          blurRadius: 0,
        ),
      ...?boxShadow,
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isFocused ? AppColors.surface : AppColors.fill),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: effectiveShadows,
      ),
      child: child,
    );
  }
}
