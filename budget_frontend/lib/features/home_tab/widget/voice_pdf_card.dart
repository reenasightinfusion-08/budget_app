import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class VoicePdfCard extends StatelessWidget {
  const VoicePdfCard({
    super.key,
    this.icon,
    this.imagePath,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.iconColor,
    this.onTap,
  });

  final IconData? icon;
  final String? imagePath;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        color: AppColors.surface,
        radius: AppBorderRadius.card,
        padding: isTablet ? const EdgeInsets.all(8) : EdgeInsets.all(10.r),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image / Icon box
          AspectRatio(
            aspectRatio: 15/8,
            child: AppCard(
              color: bgColor,
              radius: AppBorderRadius.md,
              child: Center(
                child: imagePath != null
                    ? (imagePath!.endsWith('.svg')
                        ? Padding(
                            padding: EdgeInsets.all(6.r),
                            child: SvgPicture.asset(
                              imagePath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(6.r),
                            child: Image.asset(
                              imagePath!,
                              fit: BoxFit.contain,
                            ),
                          ))
                    : (icon != null
                        ? Icon(
                            icon,
                            size: isTablet ? 32 : 40.sp,
                            color: iconColor,
                          )
                        : const SizedBox.shrink()),
              ),
            ),
          ),
          6.verticalSpace,

          // Title
          Text(
            title,
            style: AppTextStyle.subCardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          4.verticalSpace,

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyle.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          8.verticalSpace,

          // Action Button
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AppCard(
                color: AppColors.popDeep,
                radius: AppBorderRadius.pill,
                padding: isTablet
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                    : EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: AppTextStyle.buttonAction,
                    ),
                    isTablet ? const SizedBox(width: 2) : 4.horizontalSpace,
                    Icon(
                      AppIcons.chevronRight,
                      size: isTablet ? 16 : 20.sp,
                      color: AppColors.surface,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
