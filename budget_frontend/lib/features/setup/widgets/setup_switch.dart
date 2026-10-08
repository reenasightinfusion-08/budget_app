import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

class SetupSwitch extends StatelessWidget {
  const SetupSwitch({super.key, required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48.w,
        height: 28.h,
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          color: isOn ? AppColors.accent : AppColors.line,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0x40000000), blurRadius: 3.r, offset: Offset(0, 1.h)),
              ],
            ),
          ),
        ),
      );
}
