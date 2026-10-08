import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/features/auth/providers/auth_provider.dart';
import 'package:budget_frontend/features/auth/widgets/auth_error_text.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AuthProvider>().clearError());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final isSuccess = await context.read<AuthProvider>().signup(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
    if (!isSuccess || !mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.setup, (route) => false);
  }

  @override
  Widget build(BuildContext context) => SheetScaffold(
        title: 'Create your account',
        subtitle: 'Set up your login to get started.',
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: emailController,
                hint: 'Email address',
                icon: Icons.mail_outline_rounded,
                validator: AppValidators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              12.verticalSpace,
              AppTextField(
                controller: passwordController,
                hint: 'Password (6+ characters)',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: AppValidators.newPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              12.verticalSpace,
              AppTextField(
                controller: confirmController,
                hint: 'Confirm password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: AppValidators.confirmPassword(passwordController),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => submit(),
              ),
              12.verticalSpace,
              const AuthErrorText(),
              12.verticalSpace,
              AuthSubmitButton(label: 'Create account', onPressed: submit),
              const Spacer(),
              AuthFooterLink(
                prompt: 'Already have an account?',
                actionLabel: 'Log in',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
}
