import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

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
    this.totalAmount = '₹0',
    this.days,
  });

  final String title;
  final String totalAmount;
  final List<DaySpendingData>? days;

  static const List<DaySpendingData> defaultDays = [
    DaySpendingData(day: 'M', state: DayBarState.filled),
    DaySpendingData(day: 'T', state: DayBarState.current),
    DaySpendingData(day: 'W', state: DayBarState.upcoming),
    DaySpendingData(day: 'T', state: DayBarState.upcoming),
    DaySpendingData(day: 'F', state: DayBarState.upcoming),
    DaySpendingData(day: 'S', state: DayBarState.upcoming),
    DaySpendingData(day: 'S', state: DayBarState.upcoming),
  ];

  @override
  Widget build(BuildContext context) {
    final items = days ?? defaultDays;

    return AppCard(
      color: AppColors.surface,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Row: "This week" and "₹0"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.cardTitle,
              ),
              Text(
                totalAmount,
                style: AppTextStyle.cardTitle,
              ),
            ],
          ),

          // 2. Chart Space
          120.verticalSpace,

          // 3. Bottom 7 Days Row
          Row(
            children: items.map((item) {
              final isCurrent = item.state == DayBarState.current;
              final isFilled = item.state == DayBarState.filled;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? const Color(0xFF3E6EA6)
                              : isCurrent
                                  ? const Color(0xFFB5D1F8)
                                  : const Color(0xFFE5ECF4),
                          border: isCurrent
                              ? Border.all(
                                  color: const Color(0xFF3E6EA6),
                                  width: 1.5.w,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(5.r),
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
