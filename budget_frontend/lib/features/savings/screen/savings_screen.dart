import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/savings/widgets/goal_card_widget.dart';
import 'package:budget_frontend/features/savings/widgets/saving_button_widget.dart';
import 'package:budget_frontend/features/savings/widgets/total_saved_widget.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GoalBloc>().add(const LoadGoals());
      }
    });
  }

  Widget _buildTabletEmptyGoalsContainer() {
    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      border: Border.all(color: AppColors.line),
      radius: AppBorderRadius.card,
      blur: 16,
      offsetY: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
            alignment: Alignment.center,
            child: const Icon(
              AppIcons.savings,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No goals added yet',
            style: AppTextStyle.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Set your first savings target to track your progress and see how much to put aside each month.',
            style: AppTextStyle.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    ScreenUtil.enableScale(
      enableWH: () => !isTablet,
      enableText: () => !isTablet,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            context.read<GoalBloc>().add(const LoadGoals());
          },
          child: BlocBuilder<GoalBloc, GoalState>(
            builder: (context, state) {
              final goals = state.goals;

              return SingleChildScrollView(
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
                    // Header remains unchanged
                    Row(
                      children: [
                        if (widget.showBackButton) ...[
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: CircleAvatar(
                              radius: 23.r,
                              backgroundColor: AppColors.surface,
                              child: Icon(
                                AppIcons.chevronLeft,
                                color: AppColors.ink,
                                size: 25.sp,
                              ),
                            ),
                          ),
                          15.horizontalSpace,
                        ],
                        Text("Savings", style: AppTextStyle.screenTitle),
                      ],
                    ),
                    isTablet ? const SizedBox(height: 20) : 15.verticalSpace,

                    if (isTablet) ...[
                      // 1. Total Saved Hero Banner across the top
                      TotalSavedWidget(
                        totalSaved: state.totalSavedRupees,
                        monthlyAdded: state.thisMonthRupees,
                        targetTotal: state.totalTargetRupees,
                        monthlyNeeded: state.totalMonthlyNeededRupees,
                        hasGoals: goals.isNotEmpty,
                      ),
                      const SizedBox(height: 16),

                      // 2. Empty container if 0 goals, OR 2-column grid of goals
                      if (goals.isEmpty)
                        _buildTabletEmptyGoalsContainer()
                      else
                        for (int i = 0; i < goals.length; i += 2) ...[
                          if (i > 0) const SizedBox(height: 14),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: GoalCardWidget(goal: goals[i]),
                                ),
                                const SizedBox(width: 14),
                                if (i + 1 < goals.length)
                                  Expanded(
                                    child: GoalCardWidget(goal: goals[i + 1]),
                                  )
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      const SizedBox(height: 20),

                      // 3. Saving Button given maximum width across the screen
                      const SizedBox(
                        width: double.infinity,
                        child: SavingButtonWidget(),
                      ),
                    ] else ...[
                      // Mobile layout untouched
                      TotalSavedWidget(
                        totalSaved: state.totalSavedRupees,
                        monthlyAdded: state.thisMonthRupees,
                        targetTotal: state.totalTargetRupees,
                        monthlyNeeded: state.totalMonthlyNeededRupees,
                        hasGoals: goals.isNotEmpty,
                      ),
                      15.verticalSpace,

                      if (goals.isNotEmpty) ...[
                        for (final goal in goals) ...[
                          GoalCardWidget(goal: goal),
                          15.verticalSpace,
                        ],
                      ],

                      const SavingButtonWidget(),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
