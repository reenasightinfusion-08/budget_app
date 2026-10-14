import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearanceOf(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            15.verticalSpace,
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
            RecentTransactionsWidget(onSelectTab: onSelectTab),
            15.verticalSpace,
            const ThisWeekCard(),
            15.verticalSpace,
            const RecentHistory(),
            50.verticalSpace,
          ],
        ),
      ),
    );
  }
}
