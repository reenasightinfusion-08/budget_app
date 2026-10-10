import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/surface_card.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/models/easy_fix.dart';
import 'package:budget_frontend/features/wallet/widgets/budget_status_card.dart';
import 'package:budget_frontend/features/wallet/widgets/category_budget_tile.dart';
import 'package:budget_frontend/features/wallet/widgets/easy_fix_banner.dart';
import 'package:budget_frontend/features/wallet/widgets/plan_summary_text.dart';
import 'package:budget_frontend/features/wallet/widgets/wallet_header.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  late final List<BudgetCategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = BudgetCategoryModel.generateInitial(
      context.read<SetupBloc>().state.effectiveBudget,
    );
  }

  int countWithStatus(BudgetStatus status) => categories.where((c) => c.status == status).length;

  void applyEasyFix(EasyFix fix) {
    setState(() {
      fix.from.limit -= fix.amount;
      fix.to.limit += fix.amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan updated: moved ${AppFormatters.rupees(fix.amount)} to ${fix.to.label}'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  Future<void> changeBudget(int currentBudget) async {
    final newBudget = await AmountInputDialog.show(
      context,
      title: 'Change Monthly Budget',
      hint: 'Enter monthly budget',
      initialValue: currentBudget,
      fontSize: 22,
    );
    if (newBudget == null || newBudget <= 0 || !mounted) return;
    context.read<SetupBloc>().add(SetupBudgetAmountChanged(newBudget));
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = context.select<SetupBloc, int>((bloc) => bloc.state.effectiveBudget);
    final easyFix = EasyFix.find(categories);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearance.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WalletHeader(onChangeBudget: () => changeBudget(totalBudget)),
            16.verticalSpace,
            BudgetStatusTrip(
              onTrackCount: countWithStatus(BudgetStatus.onTrack),
              carefulCount: countWithStatus(BudgetStatus.careful),
              overCount: countWithStatus(BudgetStatus.over),
            ),
            16.verticalSpace,
            if (easyFix != null) ...[
              EasyFixBanner(
                amount: easyFix.amount,
                fromCategory: easyFix.from.label,
                toCategory: easyFix.to.label,
                onMove: () => applyEasyFix(easyFix),
              ),
              14.verticalSpace,
            ],
            PlanSummaryText(
              plannedTotal: categories.fold(0, (sum, c) => sum + c.limit),
              totalBudget: totalBudget,
            ),
            12.verticalSpace,
            SurfaceCard(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  for (final (index, category) in categories.indexed)
                    CategoryBudgetTile(
                      category: category,
                      showDivider: index < categories.length - 1,
                      onEditLimit: (limit) => setState(() => category.limit = limit),
                    ),
                ],
              ),
            ),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }
}
