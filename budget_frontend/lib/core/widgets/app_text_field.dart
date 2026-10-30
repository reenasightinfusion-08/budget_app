import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.prefixWidget,
    this.fillColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.onTap,
    this.onChanged,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? prefixWidget;
  final Color? fillColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Widget? suffixIcon;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  bool isObscured = true;
  bool _suppressValidation = false;

  void toggleVisibility() => setState(() => isObscured = !isObscured);

  void _handleUserTap() {
    try {
      context.read<AuthBloc>().add(const AuthErrorCleared());
    } catch (_) {}

    if (_fieldKey.currentState?.hasError == true) {
      _suppressValidation = true;
      _fieldKey.currentState?.validate();
      _suppressValidation = false;
    }
    widget.onTap?.call();
  }

  void _handleUserChange(String value) {
    try {
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state.errorMessage != null ||
          authBloc.state.googleErrorMessage != null) {
        authBloc.add(const AuthErrorCleared());
      }
    } catch (_) {}

    if (_fieldKey.currentState?.hasError == true) {
      _suppressValidation = true;
      _fieldKey.currentState?.validate();
      _suppressValidation = false;
    }
    widget.onChanged?.call(value);
  }

  OutlineInputBorder outline(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final effectiveFillColor =
        widget.fillColor ?? widget.backgroundColor ?? AppColors.fill;

    // When fillColor is pure surface/white (e.g. inside bottom sheets), provide a crisp subtle border
    final effectiveBorderColor =
        widget.borderColor ??
        (effectiveFillColor == AppColors.surface
            ? AppColors.line.withValues(alpha: 0.9)
            : effectiveFillColor);

    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      readOnly: widget.readOnly,
      validator: (value) {
        if (_suppressValidation) return null;
        return widget.validator?.call(value);
      },
      onTap: _handleUserTap,
      onChanged: _handleUserChange,
      obscureText: widget.isPassword && isObscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: AppTextStyle.input.copyWith(
        fontSize: isTablet ? 15 : 14.5.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyle.hint.copyWith(
          fontSize: isTablet ? 14 : 14.sp,
          color: AppColors.faint,
        ),
        counterText: '',
        filled: true,
        fillColor: effectiveFillColor,
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 14.w,
              vertical: isTablet ? 16.5 : 16.h,
            ),
        prefixIcon:
            widget.prefixWidget ??
            (widget.icon != null
                ? Icon(
                    widget.icon,
                    size: isTablet ? 19 : 19.sp,
                    color: AppColors.muted,
                  )
                : null),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: toggleVisibility,
                tooltip: isObscured ? 'Show password' : 'Hide password',
                color: AppColors.muted,
                icon: Icon(
                  isObscured ? AppIcons.visibility : AppIcons.visibilityOff,
                  size: 20.r,
                ),
              )
            : widget.suffixIcon,
        errorStyle: AppTextStyle.error.copyWith(
          fontSize: isTablet ? 12 : 11.5.sp,
        ),
        enabledBorder: outline(effectiveBorderColor, width: 1.0),
        focusedBorder: outline(AppColors.accent, width: 1.0),
        errorBorder: outline(AppColors.error, width: 1.0),
        focusedErrorBorder: outline(AppColors.error, width: 1.0),
      ),
    );
  }
}
