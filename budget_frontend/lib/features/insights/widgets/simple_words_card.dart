import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';

/// Plain-language summary of spending pace and last month's savings.
class SimpleWordsCard extends StatelessWidget {
  const SimpleWordsCard({super.key, required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final paceDiff = AppFormatters.rupees(data.paceDiff.abs().round());
    final baseStyle = AppTextStyle.body.copyWith(
      fontSize: 13.5.sp,
      color: AppColors.ink,
    );
    final bold = baseStyle.copyWith(fontWeight: FontWeight.w700);

    return AppCard(
      padding: EdgeInsets.all(16.r),
      color: AppColors.popSoft,
      radius: AppBorderRadius.dialog,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(color: AppColors.popDeep, shape: BoxShape.circle),
            child: Icon(AppIcons.autoAwesome, color: Colors.white, size: 18.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In simple words',
                  style: AppTextStyle.subCardTitle.copyWith(fontSize: 15.sp),
                ),
                4.verticalSpace,
                RichText(
                  text: TextSpan(
                    style: baseStyle,
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
