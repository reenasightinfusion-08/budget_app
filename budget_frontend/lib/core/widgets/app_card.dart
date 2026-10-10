import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.padding,
    required this.child,
    required this.isGradient,
    required this.radius,
  });

  final EdgeInsets? padding;
  final Widget child;
  final bool isGradient;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
   padding: padding,
      decoration:
      isGradient ?
      BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.card,
      ) : BoxDecoration(
        borderRadius: radius,
        color: AppColors.surface,
      ),
      child: child,
    );
  }
}
