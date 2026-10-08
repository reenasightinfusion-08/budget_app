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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AuthProvider>().clearError());
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final isSuccess =
        await context.read<AuthProvider>().requestPasswordReset(emailController.text.trim());
    if (!isSuccess || !mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) => SheetScaffold(
        title: 'Forgot password?',
        subtitle: 'Enter your email and we’ll send you a 6-digit code.',
        onBack: () => Navigator.of(context).pop(),
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => submit(),
              ),
              12.verticalSpace,
              const AuthErrorText(),
              12.verticalSpace,
              AuthSubmitButton(label: 'Send code', onPressed: submit),
              const Spacer(),
              AuthFooterLink(
                prompt: 'Remembered it?',
                actionLabel: 'Log in',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
}
