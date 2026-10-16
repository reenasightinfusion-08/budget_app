import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
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

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  16.h,
                  20.w,
                  widget.showBackButton ? 20.h : AppLayout.navBarClearanceOf(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    15.verticalSpace,

                    // Total Saved Card with real sums from API
                    TotalSavedWidget(
                      totalSaved: state.totalSavedRupees,
                      monthlyAdded: state.thisMonthRupees,
                      targetTotal: state.totalTargetRupees,
                      monthlyNeeded: state.totalMonthlyNeededRupees,
                      hasGoals: goals.isNotEmpty,
                    ),
                    15.verticalSpace,

                    // List of goals from API
                    if (goals.isNotEmpty) ...[
                      for (final goal in goals) ...[
                        GoalCardWidget(goal: goal),
                        15.verticalSpace,
                      ],
                    ],

                    // Button to create a new goal
                    const SavingButtonWidget(),
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
