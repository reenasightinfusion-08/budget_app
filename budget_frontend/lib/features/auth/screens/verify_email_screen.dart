import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';

import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  String? errorMessage;

  @override
  void dispose() {
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void verifyCode() {
    if (otpController.text.length < 6) {
      setState(() {
        errorMessage = 'Please enter the complete 6-digit verification code.';
      });
      return;
    }
    setState(() {
      errorMessage = null;
    });
    final isComplete = context.read<SetupBloc>().state.isComplete;
    final nextRoute = isComplete ? AppRoutes.home : AppRoutes.setup;
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
  }

  void resendCode(String userEmail) {
    if (userEmail.isNotEmpty && userEmail != 'your email') {
      context.read<AuthBloc>().add(AuthForgotPasswordRequested(email: userEmail));
    }
    setState(() {
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'your email';

    return SheetScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a 6-digit code to $userEmail',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              // Single hidden TextField capturing typing, pasting, and focus
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: otpController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onSubmitted: (_) => verifyCode(),
                ),
              ),
              // 6 OTP digit containers in a horizontal row
              GestureDetector(
                onTap: () => focusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: ListenableBuilder(
                  listenable: Listenable.merge([otpController, focusNode]),
                  builder: (context, _) {
                    final codeText = otpController.text;
                    final isFocused = focusNode.hasFocus;

                    return Row(
                      children: List.generate(6, (index) {
                        final isCurrentBoxFocused = isFocused &&
                            (codeText.length == index || (codeText.length == 6 && index == 5));
                        final hasValue = index < codeText.length;
                        final char = hasValue ? codeText[index] : '';

                        return Expanded(
                          child: Container(
                            height: 56.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: hasValue ? AppColors.surface : AppColors.fill,
                              borderRadius: AppBorderRadius.md,
                              border: Border.all(
                                color: isCurrentBoxFocused
                                    ? AppColors.accent
                                    : (hasValue ? AppColors.ink : AppColors.line),
                                width: isCurrentBoxFocused ? 2.w : 1.w,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              char,
                              style: AppTextStyle.title.copyWith(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 18.h),
                  child: Text(errorMessage ?? '', style: AppTextStyle.error),
                ),
              ),
              AppLinkButton(
                label: 'Resend code',
                onPressed: () => resendCode(userEmail),
              ),
            ],
          ),
          12.verticalSpace,
          AuthSubmitButton(label: 'Verify', onPressed: verifyCode),
          const Spacer(),
          AuthFooterLink(
            prompt: 'Wrong email?',
            actionLabel: 'Change it',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
