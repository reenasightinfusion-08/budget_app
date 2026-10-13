import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/profile/widgets/data_raw.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final setupState = context.watch<SetupBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final String userName =
        setupState.profile?.name ?? authState.user?.displayName ?? 'User';

    final int budgetAmount = setupState.budgetAmount > 0
        ? setupState.budgetAmount
        : (authState.user != null ? (authState.user!.monthlyBudget ~/ 100) : 0);

    return AppCard(
      radius: AppBorderRadius.card,
      padding: EdgeInsets.zero,
      isGradient: false,
      child: Column(
        children: [
          DataRaw(
            icon: AppIcons.history,
            title: 'Transaction history',
            subtitle: 'Every spend and income, with search',
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          DataRaw(
            icon: AppIcons.savings,
            title: 'Savings goals',
            subtitle: 'Start your first goal',
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          DataRaw(
            icon: AppIcons.wallet,
            title: 'Name & monthly budget',
            subtitle: '$userName · ${AppFormatters.rupees(budgetAmount)}',
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          DataRaw(
            icon: AppIcons.language,
            title: 'Look & colors',
            subtitle: 'Royal · Light',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
