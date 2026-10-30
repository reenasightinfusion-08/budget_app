import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:budget_frontend/features/auth/widgets/auth_google_button.dart';
import 'package:budget_frontend/features/auth/widgets/auth_or_divider.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

import 'package:budget_frontend/core/widgets/app_toast.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthSignupRequested(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  void googleSignIn() {
    context.read<AuthBloc>().add(
      const AuthGoogleSignInRequested(isSignup: true),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status ||
        (current.errorMessage != null &&
            previous.errorMessage != current.errorMessage) ||
        (current.googleErrorMessage != null &&
            previous.googleErrorMessage != current.googleErrorMessage),
    listener: (context, state) {
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (state.status == AuthStatus.authenticated) {
        final username = state.user?.displayName ?? '';
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.afterAuth(state.user),
          (route) => false,
          arguments: {'fromSignup': true, 'username': username},
        );
      } else if (state.status == AuthStatus.verificationPending) {
        Navigator.of(context).pushNamed(AppRoutes.verifyEmail);
      } else if (state.errorMessage != null &&
          (state.errorSource == null ||
              state.errorSource == AuthScreen.signup)) {
        AppToast.error(context, message: state.errorMessage!);
        context.read<AuthBloc>().add(const AuthErrorCleared());
      } else if (state.googleErrorMessage != null &&
          (state.googleErrorSource == null ||
              state.googleErrorSource == AuthScreen.signup)) {
        AppToast.error(context, message: state.googleErrorMessage!);
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    },
    child: SheetScaffold(
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
              icon: AppIcons.mail,
              validator: AppValidators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            12.verticalSpace,
            AppTextField(
              controller: passwordController,
              hint: 'Password (8+ characters)',
              icon: AppIcons.lock,
              isPassword: true,
              validator: AppValidators.newPassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            12.verticalSpace,
            AppTextField(
              controller: confirmController,
              hint: 'Confirm password',
              icon: AppIcons.lock,
              isPassword: true,
              validator: AppValidators.confirmPassword(passwordController),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => submit(),
            ),
            16.verticalSpace,
            AuthSubmitButton(label: 'Create account', onPressed: submit),
            16.verticalSpace,
            const AuthOrDivider(),
            16.verticalSpace,
            AuthGoogleButton(
              label: 'Sign up with Google',
              onPressed: googleSignIn,
            ),
            const Spacer(),
            AuthFooterLink(
              prompt: 'Already have an account?',
              actionLabel: 'Log in',
              onPressed: () {
                final authBloc = context.read<AuthBloc>();
                context.read<AuthBloc>().add(const AuthErrorCleared());
                // Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.login).then((_) {
                  if (mounted) authBloc.add(const AuthErrorCleared());
                });
              },
            ),
          ],
        ),
      ),
    ),
  );
}
