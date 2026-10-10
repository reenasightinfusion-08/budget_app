import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/glass_back_button.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, required this.subtitle, this.onBack});

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onBack != null) ...[
                      GlassBackButton(onPressed: onBack!),
                      10.verticalSpace,
                    ],
                    Text(title, style: AppTextStyle.headline),
                    10.verticalSpace,
                    Text(subtitle, style: AppTextStyle.subtitle),
                  ],
                ),
              ),
            ),
            12.horizontalSpace,
            Transform.translate(
              offset: Offset(0, 3.h),
              child: SvgPicture.asset(
                'assest/cartoon.svg',
                width: 116.w,
                height: 116.h,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      );
}
