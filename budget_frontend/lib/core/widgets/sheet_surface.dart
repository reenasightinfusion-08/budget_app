import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

class SheetSurface extends StatelessWidget {
  const SheetSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          22.w,
          30.h,
          22.w,
          26.h + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.sheet,
          boxShadow: [
            BoxShadow(
              color: AppColors.sheetShadow,
              blurRadius: 40.r,
              spreadRadius: -26.r,
              offset: Offset(0, -20.h),
            ),
          ],
        ),
        child: child,
      );
}
