import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class TransactionItemData {
   TransactionItemData({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.textColor,
    required this.color,
    required this.description,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color color;
  Color? textColor;
  final String description;
}

class TransactionItemWidget extends StatelessWidget {
  const TransactionItemWidget({
    super.key,
    required this.data,
  });

  final TransactionItemData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surface,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: AppTextStyle.metricTitle,
              ),
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: AppBorderRadius.track,
                ),
                alignment: Alignment.center,
                child: Icon(
                  data.icon,
                  size: 20.sp,
                  color: data.iconColor,
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Text(
            "₹${data.amount}",
            style: AppTextStyle.cardAmount.copyWith(
              color: data.textColor,
            ),
          ),
          2.verticalSpace,
          Text(
            data.description,
            style: AppTextStyle.metricDescription,
          ),
        ],
      ),
    );
  }
}

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1st Row: 2 items
        Row(
          children: [
            Expanded(
              child: TransactionItemWidget(
                data: TransactionItemData(
                  title: 'IN',
                  amount: '0',
                  textColor: AppColors.catHealth,
                  icon: AppIcons.arrowDownLeft,
                  iconColor: AppColors.catHealth,
                  color:AppColors.catHealth.withValues(alpha: 0.15),
                  description: 'this month',
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: TransactionItemWidget(
                data: TransactionItemData(
                  title: 'OUT',
                  amount: '0',
                  icon: AppIcons.arrowUpRight,
                  iconColor: AppColors.catShopping,
                  color:  AppColors.catShopping.withValues(alpha: 0.15),
                  description: '------------------',
                ),
              ),
            ),
          ],
        ),
        12.verticalSpace,

        // 2nd Row: 2 items
        Row(
          children: [
            Expanded(
              child: TransactionItemWidget(
                data: TransactionItemData(
                  title: 'PER DAY',
                  amount: '789',
                  icon: Icons.lock_clock,
                  iconColor: AppColors.catTravel,
                  color: AppColors.catTravel.withValues(alpha: 0.15),
                  description: 'safe to spend',
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: TransactionItemWidget(
                data: TransactionItemData(
                  title: 'TOP SPEND',
                  amount: '250',
                  icon: AppIcons.moreHoriz,
                  iconColor: AppColors.catOther,
                  color: AppColors.catOther.withValues(alpha: 0.15),
                  description: 'nothing logged yet',
                ),
              ),
            ),
          ],
        ),

        12.verticalSpace,

        // Savings Goal Banner Card
        AppCard(
          color: AppColors.surface,
          radius: AppBorderRadius.dialog,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // 1. Container with savings child
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.catBills.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.track,
                ),
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.savings,
                  size: 18.sp,
                  color: AppColors.catBills,
                ),
              ),
              12.horizontalSpace,

              // 2. Column with SAVINGS and Start a savings goal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SAVINGS',
                      style: AppTextStyle.tag.copyWith(color: AppColors.faint),
                    ),
                    2.verticalSpace,
                    Text(
                      'Start a savings goal',
                      style: AppTextStyle.subCardTitle.copyWith(fontSize: 15.sp),
                    ),
                  ],
                ),
              ),

              // 3. Upward arrow icon
              Icon(
                Icons.arrow_upward_rounded,
                size: 20.sp,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
