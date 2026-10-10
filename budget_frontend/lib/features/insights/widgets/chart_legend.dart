import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

/// "In / Out" key for the six-month chart.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ChartLegendItem(color: AppColors.pop, label: 'In', hasBorder: true),
        14.horizontalSpace,
        const ChartLegendItem(color: AppColors.accent, label: 'Out'),
      ],
    );
  }
}

class ChartLegendItem extends StatelessWidget {
  const ChartLegendItem({
    super.key,
    required this.color,
    required this.label,
    this.hasBorder = false,
  });

  final Color color;
  final String label;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: AppColors.accent, width: 1.5) : null,
          ),
        ),
        6.horizontalSpace,
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
