import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_controllers.dart';
import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/features/auth/widgets/auth_error_text.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:budget_frontend/features/auth/widgets/auth_notice_banner.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => authController.clearError());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final isSuccess = await authController.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
    if (!isSuccess || !mounted) return;
    final nextRoute = setupController.isComplete ? AppRoutes.home : AppRoutes.setup;
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    return SheetScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to pick up where your budget left off.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (arguments is String) ...[
              AuthNoticeBanner(message: arguments),
              16.verticalSpace,
            ],
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
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: AppValidators.loginPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => submit(),
            ),
            Row(
              children: [
                const Expanded(child: AuthErrorText()),
                AppLinkButton(
                  label: 'Forgot password?',
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                ),
              ],
            ),
            12.verticalSpace,
            AuthSubmitButton(label: 'Log in', onPressed: submit),
            const Spacer(),
            AuthFooterLink(
              prompt: 'New here?',
              actionLabel: 'Create an account',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signup),
            ),
          ],
        ),
      ),
    );
  }
}
