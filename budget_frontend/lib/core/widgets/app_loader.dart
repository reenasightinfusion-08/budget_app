import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 22, this.color = AppColors.accent});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size.r,
        child: CircularProgressIndicator(strokeWidth: 2.5.w, color: color),
      );
}
