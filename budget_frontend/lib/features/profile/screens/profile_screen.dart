import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final setupState = context.watch<SetupBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final String userName =
        setupState.profile?.name ?? authState.user?.displayName ?? 'User';
    final String firstLetter = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : 'U';

    final int budgetAmount = setupState.budgetAmount > 0
        ? setupState.budgetAmount
        : (authState.user != null ? (authState.user!.monthlyBudget ~/ 100) : 0);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  Text(
                    'Profile',
                    style: AppTextStyle.profileTitle.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              15.verticalSpace,
              AppCard(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
                isGradient: true,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundColor: AppColors.pop,
                      foregroundColor: AppColors.onPop,
                      child: Text(
                        firstLetter,
                        style: AppTextStyle.headline.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          userName,
                          style: AppTextStyle.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Budget ${AppFormatters.rupees(budgetAmount)} a month',
                          style: AppTextStyle.subtitle,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 23.r,
                      backgroundColor: AppColors.pop,
                      foregroundColor: AppColors.onPop,
                      child: Icon(AppIcons.filter, size: 25.sp),
                    ),
                  ],
                ),
              ),
              15.verticalSpace,
              Row(
                children: [
                  DataCard(name: "Entries"),
                  10.horizontalSpace,
                  DataCard(name: "Goals"),
                  10.horizontalSpace,
                  DataCard(name: "Months"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final String name;


  const DataCard({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: EdgeInsets.only(top: 12.h, bottom: 12.h, left: 15.w),
        isGradient: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("0", style: AppTextStyle.title),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
                6.horizontalSpace,
                Text(name, style: AppTextStyle.toggleTitle.copyWith(color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
