import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/glass_back_button.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, required this.subtitle, this.onBack});

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 44.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null) ...[
              GlassBackButton(onPressed: onBack!),
              10.verticalSpace,
            ],
            FractionallySizedBox(
              widthFactor: 0.64,
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTextStyle.headline),
            ),
            10.verticalSpace,
            FractionallySizedBox(
              widthFactor: 0.56,
              alignment: Alignment.centerLeft,
              child: Text(subtitle, style: AppTextStyle.subtitle),
            ),
          ],
        ),
      );
}
