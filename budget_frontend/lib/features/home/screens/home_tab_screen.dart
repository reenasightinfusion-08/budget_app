import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/home/widgets/account_action_button.dart';
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

  void _performLogout(BuildContext context) {
    context.read<SetupBloc>().add(const SetupReset());
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lg,
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.error,
                size: 20.sp,
              ),
            ),
            12.horizontalSpace,
            Text(
              title,
              style: AppTextStyle.title.copyWith(fontSize: 18.sp),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyle.body.copyWith(
            color: AppColors.muted,
            fontSize: 14.sp,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyle.fieldLabel.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.md,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: Text(
              confirmLabel,
              style: AppTextStyle.fieldLabel.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to log out of your account?',
      icon: AppIcons.logout,
      confirmLabel: 'Log out',
      onConfirm: () => _performLogout(context),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Delete account',
      message: 'Are you sure you want to delete your account? This action cannot be undone.',
      icon: AppIcons.delete,
      confirmLabel: 'Delete',
      onConfirm: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.signup,
          (route) => false,
        );
      },
    );
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
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
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
                      radius: 22.r,
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.accent,
                      child: Text(
                        firstLetter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: AppColors.accent,
                        ),
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
              24.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.lg,
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppIcons.shield, color: AppColors.accent, size: 20.sp),
                        8.horizontalSpace,
                        Text(
                          'Account & Security',
                          style: AppTextStyle.title.copyWith(fontSize: 16.sp),
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    Text(
                      'Signed in as ${authState.user?.email ?? userName}',
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.muted,
                        fontSize: 13.sp,
                      ),
                    ),
                    16.verticalSpace,
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 10.h,
                      children: [
                        AccountActionButton(
                          icon: AppIcons.logout,
                          label: 'Log out',
                          onPressed: () => _confirmLogout(context),
                        ),
                        AccountActionButton(
                          icon: AppIcons.delete,
                          label: 'Delete account',
                          onPressed: () => _confirmDeleteAccount(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
