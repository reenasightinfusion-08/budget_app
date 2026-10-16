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
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class AvailableToSpendCard extends StatelessWidget {
  const AvailableToSpendCard({super.key});

  String _getCurrentMonthLastDate() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    const months = [
      'Jan',
      'Feb',
      'March',
      'April',
      'May',
      'June',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthName = months[now.month - 1];
    return '$monthName $lastDay ';
  }

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    final int monthlyBudget = walletState.monthlyBudget > 0
        ? walletState.monthlyBudget
        : ((authState.user != null && authState.user!.monthlyBudget > 0)
            ? (authState.user!.monthlyBudget ~/ 100)
            : AppConfig.defaultMonthlyBudget);
    final int totalSpent = walletState.totalSpent;
    final int availableToSpend = walletState.availableToSpend;
    final double progress = walletState.spendProgress;
    final bool isOverBudget = walletState.remainingBudget < 0;

    return AppCard(
      isGradient: true,
      radius: AppBorderRadius.card,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.glassFill,
            foregroundColor: AppColors.onAccent,
            radius: 25.r,
            child: Icon(
              AppIcons.wallet,
              size: 25.sp,
            ),
          ),
          14.verticalSpace,
          Text(
            'Available to spend',
            style: AppTextStyle.title.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onAccent,
            ),
          ),
          8.verticalSpace,
          RichText(
            text: TextSpan(
              style: AppTextStyle.subtitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.onAccentMuted,
              ),
              children: [
                TextSpan(
                  text: '${AppFormatters.rupees(isOverBudget ? -walletState.remainingBudget : availableToSpend)} ',
                  style: AppTextStyle.title.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onAccent,
                  ),
                ),
                TextSpan(
                  text: isOverBudget ? 'over budget' : 'left this month',
                ),
              ],
            ),
          ),
          16.verticalSpace,
          Container(
            height: 8.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: AppBorderRadius.track,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.onAccent,
                  borderRadius: AppBorderRadius.track,
                ),
              ),
            ),
          ),
          12.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyle.chip.copyWith(
                    color: AppColors.onAccentMuted,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  text: '${AppFormatters.rupees(totalSpent)} / ${AppFormatters.rupees(monthlyBudget)}',
                ),
              ),
              Text(
                _getCurrentMonthLastDate(),
                style: AppTextStyle.chip.copyWith(
                  color: AppColors.onAccentMuted,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
