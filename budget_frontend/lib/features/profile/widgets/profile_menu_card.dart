import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/profile/widgets/data_raw.dart';
import 'package:budget_frontend/features/profile/widgets/profile_confirmation_dialog.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  void _confirmClearData(BuildContext context) {
    ProfileConfirmationDialog.show(
      context: context,
      title: 'Clear all entries',
      message:
          'Are you sure you want to delete all entries and goals? Your account and monthly budget will remain.',
      icon: AppIcons.delete,
      confirmLabel: 'Clear all',
      onConfirm: () {
        context.read<AuthBloc>().add(const AuthClearDataRequested());
        context.read<WalletBloc>().add(const RefreshWalletSummary());
        context.read<GoalBloc>().add(const LoadGoals());
      },
    );
  }

  Widget _buildTabletItem(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.card,
        //  border: Border.all(color: AppColors.faint, width: 1),
      ),
      child: ClipRRect(borderRadius: AppBorderRadius.card, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final walletState = context.watch<WalletBloc>().state;
    final setupState = context.watch<SetupBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final String userName = UserModel.resolveName(
      profileName: setupState.profile?.name,
      user: authState.user,
    );

    final int budgetAmount = walletState.monthlyBudget > 0
        ? walletState.monthlyBudget
        : ((authState.user != null && authState.user!.monthlyBudget > 0)
              ? (authState.user!.monthlyBudget ~/ 100)
              : (setupState.budgetAmount > 0
                    ? setupState.budgetAmount
                    : AppConfig.defaultMonthlyBudget));

    final historyItem = DataRaw(
      icon: AppIcons.history,
      title: 'Transaction history',
      subtitle: 'Every spend and income, with search',
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.history);
      },
    );

    final savingsItem = DataRaw(
      icon: AppIcons.savings,
      title: 'Savings goals',
      subtitle: 'Start your first goal',
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.savings, arguments: {'showBackButton': true});
      },
    );

    final budgetItem = DataRaw(
      icon: AppIcons.wallet,
      title: 'Monthly budget',
      subtitle: '$userName · ${AppFormatters.rupees(budgetAmount)}',
      onTap: () async {
        final newBudget = await AmountInputDialog.show(
          context,
          title: 'Change Monthly Budget',
          hint: 'Enter monthly budget',
          initialValue: budgetAmount,
          fontSize: 22,
        );
        if (newBudget == null || newBudget <= 0 || !context.mounted) return;
        context.read<WalletBloc>().add(UpdateMonthlyBudget(newBudget));
        context.read<SetupBloc>().add(SetupBudgetAmountChanged(newBudget));
        final currentUser = context.read<AuthBloc>().state.user;
        if (currentUser != null) {
          context.read<AuthBloc>().add(
            AuthUserUpdated(
              currentUser.copyWith(monthlyBudget: newBudget * 100),
            ),
          );
        }
        AppToast.show(context, message: 'Monthly budget updated');
      },
    );

    final clearItem = DataRaw(
      icon: AppIcons.delete,
      title: 'Clear all entries',
      subtitle: 'Deletes all entries and goals from your account',
      iconColor: AppColors.error,
      onTap: () => _confirmClearData(context),
    );

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Preferences & Features',
              style: AppTextStyle.cardTitle.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTabletItem(context, historyItem)),
                const SizedBox(width: 16),
                Expanded(child: _buildTabletItem(context, budgetItem)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildTabletItem(context, savingsItem)),
                const SizedBox(width: 16),
                Expanded(child: _buildTabletItem(context, clearItem)),
              ],
            ),
          ),
        ],
      );
    }

    return AppCard(
      radius: AppBorderRadius.card,
      padding: EdgeInsets.zero,
      isGradient: false,
      child: Column(
        children: [
          historyItem,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          savingsItem,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          budgetItem,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          clearItem,
        ],
      ),
    );
  }
}
