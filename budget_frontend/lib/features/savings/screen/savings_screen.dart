import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/savings/widgets/goal_card_widget.dart';
import 'package:budget_frontend/features/savings/widgets/saving_button_widget.dart';
import 'package:budget_frontend/features/savings/widgets/total_saved_widget.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            canPop ? 20.h : AppLayout.navBarClearance.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (canPop) ...[
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
              const TotalSavedWidget(),
              15.verticalSpace,
              const GoalCardWidget(),
              15.verticalSpace,
              const SavingButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
