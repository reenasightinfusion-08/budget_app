import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/home_tab/widget/voice_pdf_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class AddWithBudgieCard extends StatelessWidget {
  const AddWithBudgieCard({
    super.key,
    this.onScanNow,
    this.onPdfUpload,
    this.onVoice,
  });

  final VoidCallback? onScanNow;
  final VoidCallback? onPdfUpload;
  final VoidCallback? onVoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add with Budgie',
              style: AppTextStyle.cardTitle,
            ),
            Text(
              'Scan, speak or upload',
              style: AppTextStyle.subHeader,
            ),
          ],
        ),
        12.verticalSpace,

        // Main AppCard with popDeep color (Scan a bill container)
        GestureDetector(
          onTap: onScanNow,
          behavior: HitTestBehavior.opaque,
          child: AppCard(
            color: AppColors.popDeep,
            radius: AppBorderRadius.card,
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                // 1st Child: Flex 3, AppCard with transparent scan_bill.svg
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 8/7,
                    child: AppCard(
                      color: AppColors.glassFill,
                      radius: AppBorderRadius.md,
                      padding: EdgeInsets.all(6.r),
                      child: Center(
                        child: SvgPicture.asset(
                          'assest/scan_bill.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                10.horizontalSpace,

                // 2nd Child: Flex 7, Column with Title, Subtitle, and Button
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Scan a bill',
                        style: AppTextStyle.cardTitleWhite,
                      ),
                      3.verticalSpace,
                      Text(
                        'scan a recepit and i will log it for you',
                        style: AppTextStyle.cardSubtitle,
                      ),
                      8.verticalSpace,
                      AppCard(
                        color: AppColors.pop,
                        radius: AppBorderRadius.pill,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Scan now',
                              style: AppTextStyle.buttonPill,
                            ),
                            4.horizontalSpace,
                            Icon(
                              AppIcons.chevronRight,
                              size: 16.sp,
                              color: AppColors.onPop,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        12.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VoicePdfCard(
                imagePath: 'assest/voice.svg',
                bgColor: AppColors.catBills.withValues(alpha: 0.12),
                title: "Voice",
                subtitle: "Say or type it",
                buttonText: "Speak now",
                onTap: onVoice,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: VoicePdfCard(
                imagePath: 'assest/pdf.svg',
                bgColor: AppColors.catTravel.withValues(alpha: 0.12),
                title: "PDF",
                subtitle: "Bills & statements",
                buttonText: "Upload",
                onTap: onPdfUpload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
