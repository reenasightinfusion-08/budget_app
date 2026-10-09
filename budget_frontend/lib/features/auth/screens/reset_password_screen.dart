import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/widgets/auth_demo_code_banner.dart';
import 'package:budget_frontend/features/auth/widgets/auth_error_text.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthResetPasswordRequested(
          code: codeController.text.trim(),
          newPassword: passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
              arguments: state.successMessage,
            );
          }
        },
        child: SheetScaffold(
          title: 'Set a new password',
          subtitle: 'Use the code below, then pick a new password.',
          onBack: () => Navigator.of(context).pop(),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthDemoCodeBanner(),
                AppTextField(
                  controller: codeController,
                  hint: '6-digit code',
                  icon: Icons.shield_outlined,
                  validator: AppValidators.code,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: 6,
                ),
                12.verticalSpace,
                AppTextField(
                  controller: passwordController,
                  hint: 'New password (6+ characters)',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: AppValidators.newPassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                12.verticalSpace,
                AppTextField(
                  controller: confirmController,
                  hint: 'Confirm new password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: AppValidators.confirmPassword(passwordController),
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => submit(),
                ),
                Row(
                  children: [
                    const Expanded(child: AuthErrorText()),
                    AppLinkButton(
                      label: 'Get a new code',
                      onPressed: () =>
                          context.read<AuthBloc>().add(const AuthResendResetCodeRequested()),
                    ),
                  ],
                ),
                12.verticalSpace,
                AuthSubmitButton(label: 'Update password', onPressed: submit),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}
