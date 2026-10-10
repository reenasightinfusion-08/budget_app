import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/app_loader.dart';

/// Dims the screen and shows a centred loader while [isLoading] is true.
/// Place it last inside a [Stack].
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.ink.withValues(alpha: 0.28),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.lg,
            ),
            child: const AppLoader(size: 34),
          ),
        ),
      ),
    );
  }
}
