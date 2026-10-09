import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class SetupQuickAmountChip extends StatelessWidget {
  const SetupQuickAmountChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.accent : null,
            borderRadius: AppBorderRadius.pill,
            border: isSelected ? null : Border.all(color: AppColors.line, width: 1.5.w),
          ),
          child: InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onPressed();
            },
            borderRadius: AppBorderRadius.pill,
            child: SizedBox(
              height: 42.h,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: AppTextStyle.chip.copyWith(
                      color: isSelected ? AppColors.onAccent : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
