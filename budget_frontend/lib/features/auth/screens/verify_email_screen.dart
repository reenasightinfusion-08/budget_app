import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/core/widgets/common_container.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/widgets/auth_demo_code_banner.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';

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
    context.read<AuthBloc>().add(AuthVerifyEmailRequested(code: otpController.text));
  }

  void resendCode() {
    setState(() {
      errorMessage = null;
    });
    otpController.clear();
    context.read<AuthBloc>().add(const AuthResendVerifyCodeRequested());
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.select((AuthBloc bloc) => bloc.state.pendingEmail);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.afterAuth(state.user), (route) => false);
        }
      },
      child: SheetScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a 6-digit code to $userEmail',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonContainer(
            backgroundColor: AppColors.warningSoft,
            borderRadius: AppBorderRadius.md,
            borderColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            margin: EdgeInsets.only(bottom: 20.h),
            child: Text(
              'Enter the 6-digit verification code sent to your email address to verify your account and continue.',
              style: AppTextStyle.body.copyWith(
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
          const AuthDemoCodeBanner(),
          Stack(
            children: [
              // Single hidden TextField capturing typing, pasting, and focus
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: otpController,
                  focusNode: focusNode,
                  autofocus: true,
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
              MouseRegion(
                cursor: SystemMouseCursors.text,
                child: GestureDetector(
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
                            child: CommonContainer(
                              height: 56.h,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              backgroundColor: isCurrentBoxFocused
                                  ? AppColors.surface
                                  : AppColors.fill,
                              borderRadius: AppBorderRadius.md,
                              borderColor: isCurrentBoxFocused
                                  ? AppColors.accent
                                  : (hasValue ? AppColors.accent : AppColors.line),
                              isFocused: isCurrentBoxFocused,
                              alignment: Alignment.center,
                              child: hasValue
                                  ? Text(
                                      char,
                                      style: AppTextStyle.title.copyWith(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    )
                                  : (isCurrentBoxFocused
                                      ? const _BlinkingCursor()
                                      : const SizedBox.shrink()),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 18.h),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) =>
                        Text(errorMessage ?? state.errorMessage ?? '', style: AppTextStyle.error),
                  ),
                ),
              ),
              AppLinkButton(
                label: 'Resend code',
                onPressed: resendCode,
              ),
            ],
          ),
          12.verticalSpace,
          AppButton(label: 'Verify', onPressed: verifyCode),
          const Spacer(),
          AuthFooterLink(
            prompt: 'Wrong email?',
            actionLabel: 'Change it',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }
}

