import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

enum DayBarState {
  filled, // Solid blue (completed day)
  current, // Light blue with blue border (active / selected day)
  upcoming, // Muted grey-blue (upcoming / inactive day)
}

class DaySpendingData {
  const DaySpendingData({
    required this.day,
    this.amount = 0,
    this.state = DayBarState.upcoming,
  });

  final String day;
  final double amount;
  final DayBarState state;
}

class ThisWeekCard extends StatelessWidget {
  const ThisWeekCard({
    super.key,
    this.title = 'This week',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final summary = walletState.summary;

    final now = DateTime.now();
    final todayStr = AppFormatters.dateForApi(now);

    final weekStartDate = (summary != null && summary.weekStart.isNotEmpty)
        ? (DateTime.tryParse(summary.weekStart) ??
            now.subtract(Duration(days: now.weekday - 1)))
        : now.subtract(Duration(days: now.weekday - 1));

    final dailyMap = summary != null
        ? {for (final d in summary.daily) d.date: d.spentRupees}
        : <String, int>{};

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    var weekTotal = 0;

    final generatedItems = List.generate(7, (i) {
      final dayDate = DateTime(
          weekStartDate.year, weekStartDate.month, weekStartDate.day + i);
      final dateStr = AppFormatters.dateForApi(dayDate);
      final spent = dailyMap[dateStr] ?? 0;
      weekTotal += spent;

      DayBarState state;
      if (dateStr == todayStr) {
        state = DayBarState.current;
      } else if (dayDate.isBefore(DateTime(now.year, now.month, now.day))) {
        state = DayBarState.filled;
      } else {
        state = DayBarState.upcoming;
      }

      return DaySpendingData(
        day: dayLabels[i],
        amount: spent.toDouble(),
        state: state,
      );
    });

    final items = generatedItems;
    final displayTotal = AppFormatters.rupees(weekTotal);

    final double maxSpent = items
        .map((e) => e.amount)
        .fold<double>(0.0, (a, b) => a > b ? a : b);

    return AppCard(
      color: AppColors.surface,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Row: "This week" and total weekly spend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.cardTitle,
              ),
              Text(
                displayTotal,
                style: AppTextStyle.cardTitle,
              ),
            ],
          ),
          20.verticalSpace,

          // 2. Weekly Bar Chart Area matching design
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items.map((item) {
              final isCurrent = item.state == DayBarState.current;
              final isFilled = item.state == DayBarState.filled;
              final hasSpend = item.amount > 0;

              double barHeight;
              if (hasSpend && maxSpent > 0) {
                final ratio = (item.amount / maxSpent).clamp(0.0, 1.0);
                barHeight = (ratio * 84.h + 16.h).clamp(16.h, 100.h);
              } else {
                barHeight = 8.h;
              }

              Color barColor;
              BoxBorder? barBorder;

              if (isCurrent) {
                barColor = AppColors.pop;
                barBorder = Border.all(
                  color: AppColors.accent,
                  width: 1.5.w,
                );
              } else if (isFilled && hasSpend) {
                barColor = AppColors.accent;
                barBorder = null;
              } else {
                barColor = AppColors.fill;
                barBorder = null;
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 104.h,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: barHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: barColor,
                              border: barBorder,
                              borderRadius: AppBorderRadius.track,
                            ),
                          ),
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        item.day,
                        style: isCurrent
                            ? AppTextStyle.dayLabelActive
                            : AppTextStyle.dayLabel,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
