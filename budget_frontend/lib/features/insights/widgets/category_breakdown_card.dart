import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';
import 'package:budget_frontend/features/insights/widgets/category_spend_row.dart';
import 'package:budget_frontend/features/insights/widgets/insight_card.dart';

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({super.key, required this.data});

  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final spends = data.categorySpends;

    return InsightCard(
      title: 'Where it went',
      child: spends.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Text(
                  'No spending logged this month yet.',
                  style: GoogleFonts.dmSans(fontSize: 14.sp, color: AppColors.muted),
                ),
              ),
            )
          : Column(
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
