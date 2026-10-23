import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';
import 'package:budget_frontend/features/insights/widgets/category_spend_row.dart';
import 'package:budget_frontend/features/insights/widgets/insight_card.dart';

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({super.key, required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final spends = data.categorySpends;
    final isTablet = AppLayout.isTablet(context);

    if (spends.isEmpty) {
      return InsightCard(
        title: 'Where it went',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: Center(
            child: Text(
              'No spending logged this month yet.',
              style: AppTextStyle.emptyState,
            ),
          ),
        ),
      );
    }

    if (isTablet && spends.length > 1) {
      final mid = (spends.length + 1) ~/ 2;
      final leftSpends = spends.take(mid).toList();
      final rightSpends = spends.skip(mid).toList();

      return InsightCard(
        title: 'Where it went',
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final (index, spend) in leftSpends.indexed)
                      CategorySpendRow(
                        spend: spend,
                        maxAmount: data.maxCategoryAmount,
                        showDivider: index < leftSpends.length - 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(width: 1, color: AppColors.line),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final (index, spend) in rightSpends.indexed)
                      CategorySpendRow(
                        spend: spend,
                        maxAmount: data.maxCategoryAmount,
                        showDivider: index < rightSpends.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InsightCard(
      title: 'Where it went',
      child: Column(
        children: [
          for (final (index, spend) in spends.indexed)
            CategorySpendRow(
              spend: spend,
              maxAmount: data.maxCategoryAmount,
              showDivider: index < spends.length - 1,
            ),
        ],
      ),
    );
  }
}
