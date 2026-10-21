import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/profile/widgets/data_raw.dart';
import 'package:budget_frontend/features/profile/widgets/profile_confirmation_dialog.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class ProfileAccountActionsCard extends StatelessWidget {
  const ProfileAccountActionsCard({super.key});

  void _performLogout(BuildContext context) {
    context.read<SetupBloc>().add(const SetupReset());
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  void _performDeleteAccount(BuildContext context) {
    context.read<SetupBloc>().add(const SetupReset());
    context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
  }

  void _confirmLogout(BuildContext context) {
    ProfileConfirmationDialog.show(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to log out of your account?',
      icon: AppIcons.logout,
      confirmLabel: 'Log out',
      onConfirm: () => _performLogout(context),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    ProfileConfirmationDialog.show(
      context: context,
      title: 'Delete account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      icon: AppIcons.delete,
      confirmLabel: 'Delete',
      onConfirm: () => _performDeleteAccount(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return AppCard(
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
            iconBackgroundColor: AppColors.errorSoft,
            onTap: () => _confirmLogout(context),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          DataRaw(
            icon: AppIcons.delete,
            title: 'Delete account',
            subtitle: 'Permanently remove your account and data',
            iconColor: AppColors.error,
            iconBackgroundColor: AppColors.errorSoft,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }
}
