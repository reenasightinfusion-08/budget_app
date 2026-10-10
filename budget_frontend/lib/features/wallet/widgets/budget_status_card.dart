import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/widgets/surface_card.dart';

class BudgetStatusTrip extends StatelessWidget {
  const BudgetStatusTrip({
    super.key,
    required this.onTrackCount,
    required this.carefulCount,
    required this.overCount,
  });

  final int onTrackCount;
  final int carefulCount;
  final int overCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatusCountCard(count: onTrackCount, label: 'On track'),
        8.horizontalSpace,
        StatusCountCard(count: carefulCount, label: 'Careful'),
        8.horizontalSpace,
        StatusCountCard(count: overCount, label: 'Over'),
      ],
    );
  }
}

class StatusCountCard extends StatelessWidget {
  const StatusCountCard({super.key, required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SurfaceCard(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        borderRadius: AppBorderRadius.tile,
        blur: 10,
        offsetY: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
                color: AppColors.ink,
              ),
            ),
            6.verticalSpace,
            Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                6.horizontalSpace,
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
