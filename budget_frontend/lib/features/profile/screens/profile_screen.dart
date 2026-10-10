import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
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

  void _performLogout(BuildContext context) {
    context.read<SetupBloc>().add(const SetupReset());
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  void _performDeleteAccount(BuildContext context) {
    context.read<SetupBloc>().add(const SetupReset());
    context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
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
      onConfirm: () => _performDeleteAccount(context),
    );
  }

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

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated ||
          (current.errorMessage != null && previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        }
      },
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                radius: AppBorderRadius.card,
                padding: EdgeInsets.symmetric(vertical: 23.h, horizontal: 18.w),
                isGradient: true,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 33.r,
                      backgroundColor: AppColors.pop,
                      foregroundColor: AppColors.onPop,
                      child: Text(
                        firstLetter,
                        style: AppTextStyle.profileTitle.copyWith(
                          color: AppColors.onPop,
                          fontSize: 35,
                          fontWeight: FontWeight.w500
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
                  const DataCard(count: '12',name: "Entries"),
                  10.horizontalSpace,
                  const DataCard(count: '18',name: "Goals"),
                  10.horizontalSpace,
                  const DataCard(count: '6',name: "Months"),
                ],
              ),
              15.verticalSpace,
              AppCard(
                radius: AppBorderRadius.card,
                padding: EdgeInsets.zero,
                isGradient: false,
                child: Column(
                  children: [
                    DataRaw(
                      icon: AppIcons.history,
                      title: 'Transaction history',
                      subtitle: 'Every spend and income, with search',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16),
                    DataRaw(
                      icon: AppIcons.savings,
                      title: 'Savings goals',
                      subtitle: 'Start your first goal',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16),
                    DataRaw(
                      icon: AppIcons.wallet,
                      title: 'Name & monthly budget',
                      subtitle: '$userName · ${AppFormatters.rupees(budgetAmount)}',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16),
                    DataRaw(
                      icon: AppIcons.language,
                      title: 'Look & colors',
                      subtitle: 'Royal · Light',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              15.verticalSpace,
              AppCard(
                radius: AppBorderRadius.card,
                padding: EdgeInsets.zero,
                isGradient: false,
                child: Column(
                  children: [
                    DataRaw(
                      icon: AppIcons.database,
                      title: 'Load example data',
                      subtitle: 'Replace your entries with sample ones',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16),
                    DataRaw(
                      icon: AppIcons.delete,
                      title: 'Clear all entries',
                      subtitle: 'Removes entries and goals from this device',
                      iconColor: AppColors.error,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              15.verticalSpace,
              AppCard(
                radius: AppBorderRadius.card,
                padding: EdgeInsets.zero,
                isGradient: false,
                child: Column(
                  children: [
                    DataRaw(
                      icon: AppIcons.logout,
                      title: 'Log out',
                      subtitle: authState.user?.email ?? 'Signed in',
                      iconColor: AppColors.error,
                      iconBackgroundColor: const Color(0xFFFDE8E8),
                      onTap: () => _confirmLogout(context),
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 16),
                    DataRaw(
                      icon: AppIcons.delete,
                      title: 'Delete account',
                      subtitle: 'Permanently remove your account and data',
                      iconColor: AppColors.error,
                      iconBackgroundColor: const Color(0xFFFDE8E8),
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ),
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

class DataCard extends StatelessWidget {
  final String name;
  final String count;

  const DataCard({super.key, required this.name,required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: AppBorderRadius.tile,
        padding: EdgeInsets.only(top: 12.h, bottom: 12.h,),
        isGradient: false,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(count, style: AppTextStyle.title.copyWith(
              fontSize: 30,
              height: 1
            )),
            Row(
              mainAxisAlignment: .center,
              children: [
                // Container(
                //   width: 8.r,
                //   height: 8.r,
                //   decoration: const BoxDecoration(
                //     color: AppColors.muted,
                //     shape: BoxShape.circle,
                //   ),
                // ),
            //    6.horizontalSpace,
                Text(
                  name,
                  style: AppTextStyle.toggleTitle.copyWith(
                    color: AppColors.muted,
                    fontSize: 15
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DataRaw extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const DataRaw({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.card,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: iconBackgroundColor ?? AppColors.fill,
              foregroundColor: iconColor ?? AppColors.accent,
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? AppColors.accent,
              ),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.title.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  3.verticalSpace,
                  Text(
                    subtitle,
                    style: AppTextStyle.subtitle.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            Icon(
              AppIcons.chevronRight,
              color: AppColors.faint,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
