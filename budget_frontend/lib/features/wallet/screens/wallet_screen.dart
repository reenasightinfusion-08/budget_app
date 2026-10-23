import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/models/easy_fix.dart';
import 'package:budget_frontend/features/wallet/widgets/budget_status_card.dart';
import 'package:budget_frontend/features/wallet/widgets/category_budget_tile.dart';
import 'package:budget_frontend/features/wallet/widgets/easy_fix_banner.dart';
import 'package:budget_frontend/features/wallet/widgets/plan_summary_text.dart';
import 'package:budget_frontend/features/wallet/widgets/wallet_header.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().state.user;
    if (authUser != null && authUser.monthlyBudget > 0) {
      context.read<WalletBloc>().add(WalletUserSynced(authUser));
    }
    context.read<WalletBloc>().add(const LoadWallet());
  }

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
    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser != null) {
      context.read<AuthBloc>().add(AuthUserUpdated(currentUser.copyWith(monthlyBudget: newBudget * 100)));
    }
    AppToast.show(context, message: 'Monthly budget updated');
  }

  void _applyEasyFix(BuildContext context, EasyFix fix) {
    context.read<WalletBloc>().add(ApplyWalletEasyFix(fix));
    AppToast.show(
      context,
      message: 'Plan updated: moved ${AppFormatters.rupees(fix.amount)} to ${fix.to.label}',
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    BudgetCategoryModel category,
    bool showDivider,
  ) {
    return CategoryBudgetTile(
      category: category,
      showDivider: showDivider,
      onEditLimit: (limit) {
        context.read<WalletBloc>().add(
              UpdateCategoryLimit(
                categoryId: category.id,
                newLimit: limit,
              ),
            );
        AppToast.show(
          context,
          message: '${category.label} limit updated',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final authUser = context.watch<AuthBloc>().state.user;

    ScreenUtil.enableScale(
      enableWH: () => !isTablet,
      enableText: () => !isTablet,
    );

    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final totalBudget = state.monthlyBudget > 0
            ? state.monthlyBudget
            : ((authUser != null && authUser.monthlyBudget > 0)
                ? (authUser.monthlyBudget ~/ 100)
                : AppConfig.defaultMonthlyBudget);
        final categories = state.categories;
        final easyFix = state.easyFix;

        final mid = (categories.length + 1) ~/ 2;
        final leftCategories = categories.take(mid).toList();
        final rightCategories = categories.skip(mid).toList();

        final content = SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              context.read<WalletBloc>().add(const LoadWallet());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: isTablet
                  ? const EdgeInsets.fromLTRB(32, 24, 32, 120)
                  : EdgeInsets.fromLTRB(
                      20.w,
                      16.h,
                      20.w,
                      widget.showBackButton ? 20.h : AppLayout.navBarClearanceOf(context),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WalletHeader(
                    onChangeBudget: () => _changeBudget(context, totalBudget),
                    showBackButton: widget.showBackButton,
                  ),
                  isTablet ? const SizedBox(height: 20) : 16.verticalSpace,
                  BudgetStatusTrip(
                    onTrackCount: state.countWithStatus(BudgetStatus.onTrack),
                    carefulCount: state.countWithStatus(BudgetStatus.careful),
                    overCount: state.countWithStatus(BudgetStatus.over),
                  ),
                  isTablet ? const SizedBox(height: 20) : 16.verticalSpace,
                  if (easyFix != null) ...[
                    EasyFixBanner(
                      amount: easyFix.amount,
                      fromCategory: easyFix.from.label,
                      toCategory: easyFix.to.label,
                      onMove: () => _applyEasyFix(context, easyFix),
                    ),
                    isTablet ? const SizedBox(height: 16) : 14.verticalSpace,
                  ],
                  PlanSummaryText(
                    plannedTotal: state.plannedTotal,
                    totalBudget: totalBudget,
                  ),
                  isTablet ? const SizedBox(height: 16) : 12.verticalSpace,
                  AppCard(
                    width: double.infinity,
                    padding: isTablet
                        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                        : EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    border: Border.all(color: AppColors.line),
                    blur: 16,
                    offsetY: 4,
                    child: isTablet && categories.length > 1
                        ? IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      for (final (index, category) in leftCategories.indexed)
                                        _buildCategoryTile(
                                          context,
                                          category,
                                          index < leftCategories.length - 1,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Container(width: 1, color: AppColors.line),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    children: [
                                      for (final (index, category) in rightCategories.indexed)
                                        _buildCategoryTile(
                                          context,
                                          category,
                                          index < rightCategories.length - 1,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              for (final (index, category) in categories.indexed)
                                _buildCategoryTile(
                                  context,
                                  category,
                                  index < categories.length - 1,
                                ),
                            ],
                          ),
                  ),
                  isTablet ? const SizedBox(height: 32) : 24.verticalSpace,
                ],
              ),
            ),
          ),
        );

        if (widget.showBackButton) {
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
