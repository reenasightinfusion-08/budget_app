import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';
import 'package:budget_frontend/features/insights/widgets/category_breakdown_card.dart';
import 'package:budget_frontend/features/insights/widgets/chart_legend.dart';
import 'package:budget_frontend/features/insights/widgets/insight_card.dart';
import 'package:budget_frontend/features/insights/widgets/insights_header.dart';
import 'package:budget_frontend/features/insights/widgets/pace_chart.dart';
import 'package:budget_frontend/features/insights/widgets/simple_words_card.dart';
import 'package:budget_frontend/features/insights/widgets/six_month_bar_chart.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.select<SetupBloc, int>((bloc) => bloc.state.effectiveBudget);
    final data = InsightsData.mockForBudget(budget);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearance.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InsightsHeader(),
            16.verticalSpace,
            SimpleWordsCard(data: data),
            16.verticalSpace,
            InsightCard(
              title: 'Spent this month',
              trailing: Text(
                AppFormatters.rupees(data.spentThisMonth),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              subtitle: 'Stay under the dotted line and you\'ll finish inside your budget.',
              child: PaceChart(
                budget: data.budget,
                cumulativeSpending: data.cumulativeSpending,
                daysInMonth: data.daysInMonth,
              ),
            ),
            16.verticalSpace,
            InsightCard(
              title: 'Last 6 months',
              trailing: const ChartLegend(),
              child: SixMonthBarChart(records: data.monthlyRecords),
            ),
            16.verticalSpace,
            CategoryBreakdownCard(data: data),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }
}
