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
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

import 'package:budget_frontend/core/widgets/app_toast.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthForgotPasswordRequested(email: emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listenWhen: (previous, current) =>
        previous.status != current.status ||
        (current.errorMessage != null &&
            previous.errorMessage != current.errorMessage),
    listener: (context, state) {
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (state.status == AuthStatus.passwordResetSent) {
        Navigator.of(context).pushNamed(AppRoutes.resetPassword);
      } else if (state.errorMessage != null &&
          (state.errorSource == null ||
              state.errorSource == AuthScreen.forgotPassword)) {
        AppToast.error(context, message: state.errorMessage!);
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    },
    child: SheetScaffold(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we’ll send you a 6-digit code.',
      onBack: () {
        context.read<AuthBloc>().add(const AuthErrorCleared());
        Navigator.of(context).pop();
      },
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => submit(),
            ),
            16.verticalSpace,
            AuthSubmitButton(label: 'Send code', onPressed: submit),
            const Spacer(),
            AuthFooterLink(
              prompt: 'Remembered it?',
              actionLabel: 'Log in',
              onPressed: () {
                context.read<AuthBloc>().add(const AuthErrorCleared());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
