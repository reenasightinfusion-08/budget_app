import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = months[now.month - 1];
    return '$monthName ${now.year}';
  }



  @override
  Widget build(BuildContext context) {
    final setupState = context.watch<SetupBloc>().state;
    final authState = context.watch<AuthBloc>().state;

    final String userName = setupState.profile?.name ??
        authState.user?.displayName ??
        'User';
    final String firstLetter =
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, AppLayout.navBarClearance.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 23.r,
                      backgroundColor: AppColors.pop,
                      foregroundColor: AppColors.ink
                      ,
                      child: Text(
                        firstLetter,
                        style: AppTextStyle.profileTitle.copyWith(
                            color: AppColors.onPop,
                            fontSize: 25,
                            fontWeight: FontWeight.w500
                        ),
                        // style: TextStyle(
                        //   fontWeight: FontWeight.bold,
                        //   fontSize: 20.sp,
                        //   color: AppColors.accent,
                        // ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getGreetingMessage(),
                          style: AppTextStyle.fieldLabel.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          userName,
                          style: AppTextStyle.title.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppBorderRadius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 14.sp,
                          color: AppColors.accent,
                        ),
                        6.horizontalSpace,
                        Text(
                          _getFormattedDate(),
                          style: AppTextStyle.chip.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
