import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/features/history/screen/history_screen.dart';

class RecentHistory extends StatelessWidget {
  const RecentHistory({
    super.key,
    this.onSeeAll,
  });

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surface,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1st Row: "Recent" spaceBetween AppLinkButton "See all"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: AppTextStyle.cardTitle,
              ),
              AppLinkButton(
                label: 'See all',
                onPressed: onSeeAll ??
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
              ),
            ],
          ),
          20.verticalSpace,

          // 2nd Row: "Nothing yet. Tap + to log your first spend or income."
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nothing yet. Tap + to log your first spend or income.',
                  style: AppTextStyle.emptyState.copyWith(color: AppColors.faint),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          20.verticalSpace,
        ],
      ),
    );
  }
}
