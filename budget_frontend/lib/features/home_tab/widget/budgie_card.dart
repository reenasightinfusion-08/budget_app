import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class BudgieCard extends StatefulWidget {
  const BudgieCard({super.key});

  @override
  State<BudgieCard> createState() => _BudgieCardState();
}

class _BudgieCardState extends State<BudgieCard> {
  int _quoteIndex = 0;

  static const List<String> _feelingGreatQuotes = [
    "Chirp chirp! You're spending well under pace. I feel fantastic.",
    "Tweet! Keep this up and we both win.",
    "I could fly all day on this budget.",
    "Seeds for everyone!",
  ];

  static const List<String> _happyQuotes = [
    "Steady wings. You're right on track this month.",
    "Nice and calm. I like it.",
    "Small spends, big smiles.",
    "Tweet tweet. All good here.",
  ];

  static const List<String> _exhaustedQuotes = [
    "Heavy turbulence! We've flown past our spending pace.",
    "So... tired...",
    "Could we pause spending for a bit?",
    "I will bounce back once the month evens out.",
  ];

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

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day.clamp(1, daysInMonth);

    // Expected daily pace
    final allowedByToday = (monthlyBudget / daysInMonth) * currentDay;

    // Energy calculation based on month and spend ratio
    int energy;
    if (monthlyBudget <= 0 || totalSpent <= 0) {
      energy = 100;
    } else if (totalSpent >= monthlyBudget) {
      energy = 15;
    } else {
      final paceRatio = totalSpent / (allowedByToday <= 0 ? 1.0 : allowedByToday);
      if (paceRatio <= 1.0) {
        // Under pace: 60 to 100
        energy = (100 - (paceRatio * 40)).round().clamp(60, 100);
      } else if (paceRatio <= 1.5) {
        // Close to pace: 30 to 59
        energy = (59 - ((paceRatio - 1.0) / 0.5 * 29)).round().clamp(30, 59);
      } else {
        // Over pace: less than 30
        energy = (29 - ((paceRatio - 1.5) * 20)).round().clamp(5, 29);
      }
    }

    final String statusTag;
    final Color tagBgColor;
    final Color tagTextColor;
    final List<String> quotes;

    if (energy >= 60) {
      statusTag = 'Feeling great';
      tagBgColor = AppColors.catHealth.withValues(alpha: 0.15);
      tagTextColor = AppColors.catHealth;
      quotes = _feelingGreatQuotes;
    } else if (energy >= 30) {
      statusTag = 'Happy';
      tagBgColor = AppColors.popSoft;
      tagTextColor = AppColors.accent;
      quotes = _happyQuotes;
    } else {
      statusTag = 'Exhausted';
      tagBgColor = AppColors.error.withValues(alpha: 0.15);
      tagTextColor = AppColors.error;
      quotes = _exhaustedQuotes;
    }

    final currentQuote = quotes[_quoteIndex % quotes.length];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % quotes.length;
        });
      },
      child: AppCard(
        padding: EdgeInsets.all(12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First child: AspectRatio 1 with pop background color
            Expanded(
              flex: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: AppCard(
                  color: AppColors.fill,
                  radius: AppBorderRadius.card,
                  child: Center(
                    child: Text(
                 //  '🦜',
                     // '🦚',
                     '🦉',
                   //   '🐥',
                      style: TextStyle(fontSize: 50.sp),
                    ),
                  ),
                ),
              ),
            ),
            10.horizontalSpace,

            // Second child: Column
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  5.verticalSpace,
                  // 1. Row: "Budgie" text + AppCard with status color and statusTag
                  Row(
                    children: [
                      Text(
                        'Budgie',
                        style: AppTextStyle.cardTitle,
                      ),
                      8.horizontalSpace,
                      AppCard(
                        color: tagBgColor,
                        radius: AppBorderRadius.pill,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        child: Text(
                          statusTag,
                          style: AppTextStyle.tag.copyWith(
                            fontSize: 12.sp,
                            color: tagTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  5.verticalSpace,

                  // 2. Text: Dynamic speech quote
                  Text(
                    currentQuote,
                    style: AppTextStyle.body.copyWith(
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  7.verticalSpace,

                  // 3. Row: "Energy" + AppProgressBar + energy
                  Row(
                    children: [
                      Text(
                        'Energy',
                        style: AppTextStyle.description.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: AppProgressBar(
                          ratio: (energy / 100.0).clamp(0.0, 1.0),
                          height: 7,
                          color: AppColors.popDeep,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        '$energy',
                        style: AppTextStyle.fieldLabel.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  5.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
