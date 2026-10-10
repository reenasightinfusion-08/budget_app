import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.padding,
    required this.child,
    required this.isGradient,
  });

  final EdgeInsets? padding;
  final Widget child;
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
   padding: padding,
      decoration:
      isGradient ?
      BoxDecoration(
        borderRadius: AppBorderRadius.card,
        gradient: AppGradients.card,
      ) : BoxDecoration(
        borderRadius: AppBorderRadius.card,
        color: AppColors.surface
      ),
      child: child,
    );
  }
}
