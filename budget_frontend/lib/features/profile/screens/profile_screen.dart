import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/profile/widgets/profile_account_actions_card.dart';
import 'package:budget_frontend/features/profile/widgets/profile_header.dart';
import 'package:budget_frontend/features/profile/widgets/profile_menu_card.dart';
import 'package:budget_frontend/features/profile/widgets/profile_stats_row.dart';
import 'package:budget_frontend/features/profile/widgets/profile_user_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated ||
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          (current.successMessage != null &&
              previous.successMessage != current.successMessage),
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state.errorMessage != null) {
          AppToast.show(
            context,
            message: state.errorMessage!,
            backgroundColor: AppColors.error,
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        } else if (state.successMessage != null) {
          AppToast.show(
            context,
            message: state.successMessage!,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileHeader(),
                15.verticalSpace,
                const ProfileUserCard(),
                15.verticalSpace,
                const ProfileStatsRow(),
                15.verticalSpace,
                const ProfileMenuCard(),
                15.verticalSpace,
                const ProfileAccountActionsCard(),
                20.verticalSpace,
                Center(
                  child: Text(
                    'Your entries stay on this device only.',
                    style: AppTextStyle.subtitle.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
