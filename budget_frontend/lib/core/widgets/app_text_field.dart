import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

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

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  bool isObscured = true;

  void toggleVisibility() => setState(() => isObscured = !isObscured);

  OutlineInputBorder outline(Color color) => OutlineInputBorder(
        borderRadius: AppBorderRadius.md,
        borderSide: BorderSide(color: color, width: 1.5.w),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
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
                  isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
