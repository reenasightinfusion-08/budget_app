import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/auth/widgets/auth_demo_code_banner.dart';
import 'package:budget_frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:budget_frontend/features/auth/widgets/auth_submit_button.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';

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
  void initState() {
    super.initState();
    otpController.addListener(_onOtpChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusOtpInput();
      }
    });
  }

  void _focusOtpInput() {
    if (errorMessage != null ||
        context.read<AuthBloc>().state.errorMessage != null) {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    }

    otpController.selection = TextSelection.collapsed(
      offset: otpController.text.length,
    );

    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    FocusScope.of(context).requestFocus(focusNode);
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  void _onOtpChanged() {
    if (errorMessage != null ||
        context.read<AuthBloc>().state.errorMessage != null) {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
        context.read<AuthBloc>().add(const AuthErrorCleared());
      }
    }
  }

  @override
  void dispose() {
    otpController.removeListener(_onOtpChanged);
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void verifyCode() {
    if (otpController.text.length < 6) {
      AppToast.error(context, message: 'Enter 6-digit code');
      return;
    }
    context.read<AuthBloc>().add(
      AuthVerifyEmailRequested(code: otpController.text),
    );
  }

  void resendCode() {
    otpController.clear();
    context.read<AuthBloc>().add(const AuthResendVerifyCodeRequested());
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.select(
      (AuthBloc bloc) => bloc.state.pendingEmail,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state.status == AuthStatus.authenticated) {
          final username = state.user?.displayName ?? '';
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.afterAuth(state.user),
            (route) => false,
            arguments: {'fromSignup': true, 'username': username},
          );
        } else if (state.errorMessage != null &&
            (state.errorSource == null ||
                state.errorSource == AuthScreen.verifyEmail)) {
          AppToast.error(context, message: state.errorMessage!);
          context.read<AuthBloc>().add(const AuthErrorCleared());
        }
      },
      child: SheetScaffold(
        title: 'Verify your email',
        subtitle: 'We sent a 6-digit code to $userEmail',
        onBack: () {
          context.read<AuthBloc>().add(const AuthErrorCleared());
          Navigator.of(context).pop();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              color: AppColors.warningSoft,
              radius: AppBorderRadius.md,
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
                    enableSuggestions: false,
                    autocorrect: false,
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
                    onTap: _focusOtpInput,
                    behavior: HitTestBehavior.opaque,
                    child: ListenableBuilder(
                      listenable: Listenable.merge([otpController, focusNode]),
                      builder: (context, _) {
                        final codeText = otpController.text;
                        final isFocused = focusNode.hasFocus;

                        return Row(
                          children: List.generate(6, (index) {
                            final isCurrentBoxFocused =
                                isFocused &&
                                (codeText.length == index ||
                                    (codeText.length == 6 && index == 5));
                            final hasValue = index < codeText.length;
                            final char = hasValue ? codeText[index] : '';

                            return Expanded(
                              child: AppCard(
                                height: 56.h,
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                color: isCurrentBoxFocused
                                    ? AppColors.surface
                                    : AppColors.fill,
                                radius: AppBorderRadius.md,
                                border: Border.all(
                                  color: isCurrentBoxFocused
                                      ? AppColors.accent
                                      : (hasValue
                                            ? AppColors.accent
                                            : AppColors.line),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  if (isCurrentBoxFocused)
                                    BoxShadow(
                                      color: AppColors.fill,
                                      spreadRadius: 3.0,
                                      blurRadius: 0,
                                    ),
                                ],
                                child: Center(
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
            8.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: AppLinkButton(label: 'Resend code', onPressed: resendCode),
            ),
            12.verticalSpace,
            AuthSubmitButton(label: 'Verify', onPressed: verifyCode),
            const Spacer(),
            AuthFooterLink(
              prompt: 'Wrong email?',
              actionLabel: 'Change it',
              onPressed: () {
                context.read<AuthBloc>().add(const AuthErrorCleared());
                Navigator.of(context).pop();
              },
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
          borderRadius: AppBorderRadius.indicator,
        ),
      ),
    );
  }
}
