import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';

class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.glassFill,
        shape: CircleBorder(side: BorderSide(color: AppColors.glassBorder, width: 1.w)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed();
          },
          child: SizedBox.square(
            dimension: 44.r,
            child: Icon(AppIcons.chevronLeft, size: 26.r, color: AppColors.onAccent),
          ),
        ),
      );
}
