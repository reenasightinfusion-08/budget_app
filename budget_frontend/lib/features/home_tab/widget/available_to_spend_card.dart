import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
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
    return '${AppFormatters.monthShort(now.month)} $lastDay';
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

    final isTablet = AppLayout.isTablet(context);

    return ClipRRect(
      borderRadius: AppBorderRadius.card,
      child: Stack(
        children: [
          AppCard(
            isGradient: true,
            radius: AppBorderRadius.card,
            padding: isTablet ? const EdgeInsets.all(24) : EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Title & Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Available to Spend',
                      style: AppTextStyle.subtitle.copyWith(
                        fontSize: isTablet ? 15 : 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onAccentMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 9.w,
                        vertical: isTablet ? 5 : 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isOverBudget
                            ? AppColors.error.withValues(alpha: 0.3)
                            : AppColors.glassFill,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: isOverBudget
                              ? AppColors.onAccentError.withValues(alpha: 0.45)
                              : AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOverBudget
                                  ? AppColors.onAccentError
                                  : const Color(0xFF68D391),
                            ),
                          ),
                          6.horizontalSpace,
                          Text(
                            isOverBudget
                                ? 'Over Budget'
                                : '${(progress * 100).toInt()}% Used',
                            style: AppTextStyle.tag.copyWith(
                              color: isOverBudget
                                  ? AppColors.onAccentError
                                  : AppColors.onAccent,
                              fontSize: isTablet ? 11 : 10.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                isTablet ? const SizedBox(height: 10) : 8.verticalSpace,

                // Big Hero Amount
                Text(
                  AppFormatters.rupees(
                    isOverBudget
                        ? -walletState.remainingBudget
                        : availableToSpend,
                  ),
                  style: AppTextStyle.amount.copyWith(
                    fontSize: isTablet ? 36 : 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: AppColors.onAccent,
                    height: 1.1,
                  ),
                ),
                isTablet ? const SizedBox(height: 4) : 4.verticalSpace,

                // Explanatory Subtitle
                Text(
                  isOverBudget
                      ? 'Exceeded monthly budget by ${AppFormatters.rupees(-walletState.remainingBudget)}'
                      : '${AppFormatters.rupees(availableToSpend)} remaining for this month',
                  style: AppTextStyle.subtitle.copyWith(
                    fontSize: isTablet ? 13 : 12.5.sp,
                    color: isOverBudget
                        ? AppColors.onAccentError
                        : AppColors.onAccentMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                isTablet ? const SizedBox(height: 16) : 15.verticalSpace,

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: isTablet ? 6 : 6.h,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.18),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isOverBudget
                              ? AppColors.onAccentError
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                isTablet ? const SizedBox(height: 14) : 12.verticalSpace,

                // Bottom Stats Row: Spent vs Budget & Month-end date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Spent ',
                          style: AppTextStyle.chip.copyWith(
                            color: AppColors.onAccentMuted,
                            fontSize: isTablet ? 12 : 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          AppFormatters.rupees(totalSpent),
                          style: AppTextStyle.chip.copyWith(
                            color: AppColors.onAccent,
                            fontSize: isTablet ? 12.5 : 12.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' of ${AppFormatters.rupees(monthlyBudget)}',
                          style: AppTextStyle.chip.copyWith(
                            color: AppColors.onAccentMuted,
                            fontSize: isTablet ? 12 : 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 8 : 7.w,
                        vertical: isTablet ? 3 : 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _getCurrentMonthLastDate(),
                        style: AppTextStyle.chip.copyWith(
                          color: AppColors.onAccent,
                          fontSize: isTablet ? 11 : 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Decorative Glassmorphism Background Circles
          Positioned(
            right: -25.r,
            top: -25.r,
            child: IgnorePointer(
              child: Container(
                width: 125.r,
                height: 125.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40.r,
            top: -50.r,
            child: IgnorePointer(
              child: Container(
                width: 105.r,
                height: 105.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
