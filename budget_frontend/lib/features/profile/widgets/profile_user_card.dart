import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final setupState = context.watch<SetupBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final String userName =
        setupState.profile?.name ?? authState.user?.displayName ?? 'User';
    final String firstLetter = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : 'U';

    final int budgetAmount = walletState.monthlyBudget > 0
        ? walletState.monthlyBudget
        : ((authState.user != null && authState.user!.monthlyBudget > 0)
            ? (authState.user!.monthlyBudget ~/ 100)
            : (setupState.budgetAmount > 0
                ? setupState.budgetAmount
                : AppConfig.defaultMonthlyBudget));

    return AppCard(
      radius: AppBorderRadius.card,
      padding: EdgeInsets.symmetric(vertical: 23.h, horizontal: 18.w),
      isGradient: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 33.r,
            backgroundColor: AppColors.glassFill,
            foregroundColor: AppColors.surface,
            child: Text(
              firstLetter,
              style: AppTextStyle.profileTitle.copyWith(
                color: AppColors.surface,
                fontSize: 35.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: AppTextStyle.title.copyWith(
                  color: AppColors.surface,
                ),
              ),
              Text(
                'Budget ${AppFormatters.rupees(budgetAmount)} a month',
                style: AppTextStyle.subtitle.copyWith(color: AppColors.surface),
              ),
            ],
          ),
          CircleAvatar(
            radius: 23.r,
            backgroundColor: AppColors.glassFill,
            foregroundColor: AppColors.surface,
            child: Icon(AppIcons.filter, size: 25.sp),
          ),
        ],
      ),
    );
  }
}
