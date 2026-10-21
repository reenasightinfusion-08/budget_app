import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/features/home_tab/widget/add_with_budgie_card.dart';
import 'package:budget_frontend/features/home_tab/widget/available_to_spend_card.dart';
import 'package:budget_frontend/features/home_tab/widget/budgie_card.dart';
import 'package:budget_frontend/features/home_tab/widget/home_header.dart';
import 'package:budget_frontend/features/home_tab/widget/quick_action_buttons.dart';
import 'package:budget_frontend/features/home_tab/widget/pdf_bill_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/recent_history.dart';
import 'package:budget_frontend/features/home_tab/widget/recent_transactions_widget.dart';
import 'package:budget_frontend/features/home_tab/widget/scan_bill_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/this_week_card.dart';
import 'package:budget_frontend/features/home_tab/widget/voice_bill_bottom_sheet.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  Future<void> _onRefresh() async {
    context.read<WalletBloc>().add(const LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    // Keep 100% original ScreenUtil scaling for mobile.
    // For tablet, disable non-proportional scaling so card contents
    // retain their true 1:1 designed proportions without blowing up paddings.
    ScreenUtil.enableScale(
      enableWH: () => !isTablet,
      enableText: () => !isTablet,
    );

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: isTablet
              ? const EdgeInsets.fromLTRB(30, 16, 30, 120)
              : EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearanceOf(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              isTablet ? const SizedBox(height: 16) : 15.verticalSpace,
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AvailableToSpendCard(),
                          const SizedBox(height: 16),
                          const BudgieCard(),
                          const SizedBox(height: 16),
                          const QuickActionButtons(),
                          const SizedBox(height: 16),
                          AddWithBudgieCard(
                            onScanNow: () => ScanBillBottomSheet.show(context),
                            onPdfUpload: () => PdfBillBottomSheet.show(context),
                            onVoice: () => VoiceBillBottomSheet.show(context),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RecentTransactionsWidget(onSelectTab: widget.onSelectTab),
                          const SizedBox(height: 16),
                          const ThisWeekCard(),
                          const SizedBox(height: 16),
                          const RecentHistory(),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                const AvailableToSpendCard(),
                15.verticalSpace,
                const BudgieCard(),
                15.verticalSpace,
                const QuickActionButtons(),
                15.verticalSpace,
                AddWithBudgieCard(
                  onScanNow: () => ScanBillBottomSheet.show(context),
                  onPdfUpload: () => PdfBillBottomSheet.show(context),
                  onVoice: () => VoiceBillBottomSheet.show(context),
                ),
                15.verticalSpace,
                RecentTransactionsWidget(onSelectTab: widget.onSelectTab),
                15.verticalSpace,
                const ThisWeekCard(),
                15.verticalSpace,
                const RecentHistory(),
                50.verticalSpace,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

