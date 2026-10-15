import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/models/easy_fix.dart';
import 'package:budget_frontend/features/wallet/widgets/budget_status_card.dart';
import 'package:budget_frontend/features/wallet/widgets/category_budget_tile.dart';
import 'package:budget_frontend/features/wallet/widgets/easy_fix_banner.dart';
import 'package:budget_frontend/features/wallet/widgets/plan_summary_text.dart';
import 'package:budget_frontend/features/wallet/widgets/wallet_header.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  Future<void> _changeBudget(BuildContext context, int currentBudget) async {
    final newBudget = await AmountInputDialog.show(
      context,
      title: 'Change Monthly Budget',
      hint: 'Enter monthly budget',
      initialValue: currentBudget,
      fontSize: 22,
    );
    if (newBudget == null || newBudget <= 0 || !context.mounted) return;
    context.read<WalletBloc>().add(UpdateMonthlyBudget(newBudget));
    context.read<SetupBloc>().add(SetupBudgetAmountChanged(newBudget));
  }

  void _applyEasyFix(BuildContext context, EasyFix fix) {
    context.read<WalletBloc>().add(ApplyWalletEasyFix(fix));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan updated: moved ${AppFormatters.rupees(fix.amount)} to ${fix.to.label}'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.dialogInput),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final totalBudget = state.monthlyBudget;
        final categories = state.categories;
        final easyFix = state.easyFix;

        final content = SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              showBackButton ? 20.h : AppLayout.navBarClearanceOf(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WalletHeader(
                  onChangeBudget: () => _changeBudget(context, totalBudget),
                  showBackButton: showBackButton,
                ),
                16.verticalSpace,
                BudgetStatusTrip(
                  onTrackCount: state.countWithStatus(BudgetStatus.onTrack),
                  carefulCount: state.countWithStatus(BudgetStatus.careful),
                  overCount: state.countWithStatus(BudgetStatus.over),
                ),
                16.verticalSpace,
                if (easyFix != null) ...[
                  EasyFixBanner(
                    amount: easyFix.amount,
                    fromCategory: easyFix.from.label,
                    toCategory: easyFix.to.label,
                    onMove: () => _applyEasyFix(context, easyFix),
                  ),
                  14.verticalSpace,
                ],
                PlanSummaryText(
                  plannedTotal: state.plannedTotal,
                  totalBudget: totalBudget,
                ),
                12.verticalSpace,
                AppCard(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  border: Border.all(color: AppColors.line),
                  blur: 16,
                  offsetY: 4,
                  child: Column(
                    children: [
                      for (final (index, category) in categories.indexed)
                        CategoryBudgetTile(
                          category: category,
                          showDivider: index < categories.length - 1,
                          onEditLimit: (limit) {
                            context.read<WalletBloc>().add(
                                  UpdateCategoryLimit(
                                    categoryId: category.id,
                                    newLimit: limit,
                                  ),
                                );
                          },
                        ),
                    ],
                  ),
                ),
                24.verticalSpace,
              ],
            ),
          ),
        );

        if (showBackButton) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: content,
          );
        }
        return content;
      },
    );
  }
}
