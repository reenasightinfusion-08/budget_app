import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.ratio,
    required this.height,
    this.color,
    this.gradient,
  });

  final double ratio;
  final double height;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(4.r);

    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.fill, borderRadius: radius),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(color: color, gradient: gradient, borderRadius: radius),
        ),
      ),
    );
  }
}
