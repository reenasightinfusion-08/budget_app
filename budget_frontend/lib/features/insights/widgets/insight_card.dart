import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

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
    return AppCard(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      border: Border.all(color: AppColors.line),
      blur: 16,
      offsetY: 4,
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
              style: AppTextStyle.subHeader.copyWith(height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
