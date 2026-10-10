 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();
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
      if (authBloc.state.errorMessage != null || authBloc.state.googleErrorMessage != null) {
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

  OutlineInputBorder outline(Color color) => OutlineInputBorder(
        borderRadius: AppBorderRadius.md,
        borderSide: BorderSide(color: color, width: 1.5.w),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      validator: (value) {
        if (_suppressValidation) return null;
        return widget.validator(value);
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
      style: AppTextStyle.input,
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyle.hint,
        counterText: '',
        filled: true,
        fillColor: AppColors.fill,
        contentPadding: EdgeInsets.symmetric(vertical: 19.h),
        prefixIcon: Icon(widget.icon, size: 20.r),
        prefixIconColor: WidgetStateColor.fromMap({
          WidgetState.error: AppColors.error,
          WidgetState.focused: AppColors.accent,
          WidgetState.any: AppColors.muted,
        }),
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
            : null,
        errorStyle: AppTextStyle.error,
        enabledBorder: outline(AppColors.fill),
        focusedBorder: outline(AppColors.accent),
        errorBorder: outline(AppColors.error),
        focusedErrorBorder: outline(AppColors.error),
      ),
    );
  }
}
