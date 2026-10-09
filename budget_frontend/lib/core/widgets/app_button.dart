import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_loader.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final canTap = onPressed != null && !isLoading;

    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: AppBorderRadius.lg,
          ),
          child: InkWell(
            onTap: canTap
                ? () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onPressed?.call();
                  }
                : null,
            borderRadius: AppBorderRadius.lg,
            child: Container(
              height: 62.h,
              padding: EdgeInsets.only(left: 28.w, right: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyle.button),
                  Container(
                    width: 46.r,
                    height: 46.r,
                    decoration: const BoxDecoration(
                      color: AppColors.pop,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isLoading) const AppLoader(size: 20, color: AppColors.onPop),
                        if (!isLoading)
                          Icon(Icons.chevron_right_rounded, size: 26.r, color: AppColors.onPop),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
