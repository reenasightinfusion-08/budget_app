import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';

/// Says how the sum of category limits compares with the monthly budget.
class PlanSummaryText extends StatelessWidget {
  const PlanSummaryText({super.key, required this.plannedTotal, required this.totalBudget});

  final int plannedTotal;
  final int totalBudget;

  String get summary {
    final budget = AppFormatters.rupees(totalBudget);
    if (plannedTotal == totalBudget) return 'Your plans add up to your $budget budget.';
    if (plannedTotal < totalBudget) {
      return '${AppFormatters.rupees(totalBudget - plannedTotal)} of your $budget budget isn\'t planned yet.';
    }
    return 'Your plans are ${AppFormatters.rupees(plannedTotal - totalBudget)} more than your $budget budget.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        '$summary Tap an amount to change it.',
        style: AppTextStyle.description.copyWith(fontSize: 13.sp, height: 1.4),
      ),
    );
  }
}
