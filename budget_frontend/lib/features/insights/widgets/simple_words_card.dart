import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';

/// Plain-language summary of spending pace and last month's savings.
class SimpleWordsCard extends StatelessWidget {
  const SimpleWordsCard({super.key, required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);
    final paceDiff = AppFormatters.rupees(data.paceDiff.abs().round());

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.popSoft,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(color: AppColors.popDeep, shape: BoxShape.circle),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In simple words',
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                4.verticalSpace,
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(fontSize: 13.5.sp, height: 1.45, color: AppColors.ink),
                    children: [
                      const TextSpan(text: "You've spent "),
                      TextSpan(text: '$paceDiff ${data.isUnderPace ? 'less' : 'more'}', style: bold),
                      const TextSpan(text: ' than an even pace would allow by today. '),
                      TextSpan(text: 'In ${data.previousMonthName} you kept '),
                      TextSpan(text: AppFormatters.rupees(data.previousMonthSaved), style: bold),
                      TextSpan(text: ', about ${data.previousMonthSavePercentage}% of what came in.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
