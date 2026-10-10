import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/surface_card.dart';

/// Section card with a title row (optional trailing widget), content, and optional footnote.
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyle.cardTitle),
              ?trailing,
            ],
          ),
          14.verticalSpace,
          child,
          if (subtitle != null) ...[
            12.verticalSpace,
            Text(
              subtitle!,
              style: GoogleFonts.dmSans(fontSize: 13.sp, color: AppColors.muted, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
