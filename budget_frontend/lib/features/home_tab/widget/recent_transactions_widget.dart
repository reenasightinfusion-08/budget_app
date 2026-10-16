import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/screen/history_screen.dart';
import 'package:budget_frontend/features/home/widgets/home_tab_scope.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

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
    this.onTap,
  });

  final TransactionItemData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard(
        color: AppColors.surface,
        radius: AppBorderRadius.card,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 17.w, 20.h),
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
                height: 1
              ),
            ),
            4.verticalSpace,
            Text(
              data.description,
              style: AppTextStyle.metricDescription,
            ),
          ],
        ),
      ),
    );
  }
}

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  void _selectTab(BuildContext context, int index) {
    if (onSelectTab != null) {
      onSelectTab!(index);
    } else {
      HomeTabScope.selectTab(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final summary = walletState.summary;

    // IN amount
    final incomeRupees = summary?.incomeRupees ?? 0;
    final incomeText = AppFormatters.rupees(incomeRupees).replaceAll('₹', '');

    // OUT amount
    final expenseRupees = summary != null ? summary.expenseRupees : walletState.totalSpent;
    final expenseText = AppFormatters.rupees(expenseRupees).replaceAll('₹', '');

    // OUT description: compare with last month so far if available
    String outDescription = 'this month';
    if (summary != null && summary.previousMonthSoFarRupees > 0) {
      final prev = summary.previousMonthSoFarRupees;
      final diff = ((summary.expenseRupees - prev) / prev * 100).round();
      if (diff < 0) {
        outDescription = '${-diff}% less than last mo';
      } else if (diff > 0) {
        outDescription = '$diff% more than last mo';
      } else {
        outDescription = 'same as last month';
      }
    }

    // PER DAY safe spend
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, daysInMonth);
    final perDaySafe = walletState.availableToSpend > 0
        ? (walletState.availableToSpend / daysLeft).round()
        : 0;
    final perDayText = AppFormatters.rupees(perDaySafe).replaceAll('₹', '');

    // TOP SPEND category
    final topCat = summary?.topExpenseCategory;
    final topSpendAmount = topCat != null
        ? AppFormatters.rupees(topCat.totalRupees).replaceAll('₹', '')
        : '0';
    final topSpendDesc = topCat != null
        ? HistoryTransactionModel.categoryKeyToLabel(topCat.category)
        : 'nothing logged yet';
    final topSpendIcon = topCat != null
        ? HistoryTransactionModel.categoryKeyToIcon(topCat.category)
        : AppIcons.moreHoriz;
    final topSpendColor = topCat != null
        ? HistoryTransactionModel.categoryKeyToColor(topCat.category)
        : AppColors.catOther;

    return Column(
      children: [
        // 1st Row: 2 items (IN & OUT)
        Row(
          children: [
            Expanded(
              child: TransactionItemWidget(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(initialFilterIndex: 2),
                    ),
                  );
                },
                data: TransactionItemData(
                  title: 'IN',
                  amount: incomeText,
                  textColor: AppColors.catHealth,
                  icon: AppIcons.arrowDownLeft,
                  iconColor: AppColors.catHealth,
                  color: AppColors.catHealth.withValues(alpha: 0.15),
                  description: 'this month',
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: TransactionItemWidget(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(initialFilterIndex: 1),
                    ),
                  );
                },
                data: TransactionItemData(
                  title: 'OUT',
                  amount: expenseText,
                  icon: AppIcons.arrowUpRight,
                  iconColor: AppColors.catShopping,
                  color: AppColors.catShopping.withValues(alpha: 0.15),
                  description: outDescription,
                ),
              ),
            ),
          ],
        ),
        12.verticalSpace,

        // 2nd Row: 2 items (PER DAY & TOP SPEND)
        Row(
          children: [
            Expanded(
              child: TransactionItemWidget(
                data: TransactionItemData(
                  title: 'PER DAY',
                  amount: perDayText,
                  icon: Icons.lock_clock,
                  iconColor: AppColors.catTravel,
                  color: AppColors.catTravel.withValues(alpha: 0.15),
                  description: '$daysLeft days left',
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: TransactionItemWidget(
                onTap: () => _selectTab(context, 2),
                data: TransactionItemData(
                  title: 'TOP SPEND',
                  amount: topSpendAmount,
                  icon: topSpendIcon,
                  iconColor: topSpendColor,
                  color: topSpendColor.withValues(alpha: 0.15),
                  description: topSpendDesc,
                ),
              ),
            ),
          ],
        ),


        12.verticalSpace,

        // Savings Goal Banner Card
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _selectTab(context, 3),
          child: AppCard(
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
        ),
      ],
    );
  }
}
