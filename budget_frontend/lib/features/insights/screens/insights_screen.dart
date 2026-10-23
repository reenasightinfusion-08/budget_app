import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';
import 'package:budget_frontend/features/insights/widgets/category_breakdown_card.dart';
import 'package:budget_frontend/features/insights/widgets/chart_legend.dart';
import 'package:budget_frontend/features/insights/widgets/insight_card.dart';
import 'package:budget_frontend/features/insights/widgets/insights_header.dart';
import 'package:budget_frontend/features/insights/widgets/pace_chart.dart';
import 'package:budget_frontend/features/insights/widgets/simple_words_card.dart';
import 'package:budget_frontend/features/insights/widgets/six_month_bar_chart.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final walletState = context.watch<WalletBloc>().state;
    final budget = walletState.monthlyBudget;
    final summary = walletState.summary;
    final data = summary != null
        ? InsightsData.fromSummaryAndBudget(summary, budget)
        : InsightsData.empty(budget);

    ScreenUtil.enableScale(
      enableWH: () => !isTablet,
      enableText: () => !isTablet,
    );

    final spentThisMonthCard = InsightCard(
      title: 'Spent this month',
      trailing: Text(
        AppFormatters.rupees(data.spentThisMonth),
        style: AppTextStyle.dialogTitle,
      ),
      subtitle: 'Stay under the dotted line and you\'ll finish inside your budget.',
      child: PaceChart(
        budget: data.budget,
        cumulativeSpending: data.cumulativeSpending,
        daysInMonth: data.daysInMonth,
      ),
    );

    final last6MonthsCard = InsightCard(
      title: 'Last 6 months',
      trailing: const ChartLegend(),
      child: SixMonthBarChart(records: data.monthlyRecords),
    );

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          context.read<WalletBloc>().add(const LoadWallet());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: isTablet
              ? const EdgeInsets.fromLTRB(30, 20, 30, 120)
              : EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearanceOf(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InsightsHeader(),
              isTablet ? const SizedBox(height: 16) : 16.verticalSpace,
              SimpleWordsCard(data: data),
              isTablet ? const SizedBox(height: 16) : 16.verticalSpace,
              if (isTablet) ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: spentThisMonthCard),
                      const SizedBox(width: 16),
                      Expanded(child: last6MonthsCard),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                spentThisMonthCard,
                16.verticalSpace,
                last6MonthsCard,
                16.verticalSpace,
              ],
              CategoryBreakdownCard(data: data),
              isTablet ? const SizedBox(height: 24) : 24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
