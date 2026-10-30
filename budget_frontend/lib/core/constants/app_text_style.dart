import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

class AppTextStyle {
  static const String fontFamily = 'DMSans';

  static TextStyle _dmSans({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  // Display & Amounts
  static TextStyle get amount => _dmSans(
    fontSize: 48.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.16.sp,
    height: 1.1,
    color: AppColors.onAccent,
  );

  static TextStyle get headline => _dmSans(
    fontSize: 36.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.44.sp,
    height: 1.04,
    color: AppColors.onAccent,
  );

  static TextStyle get splashTitle => TextStyle(
    fontFamily: 'DMSans-Bold',
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.9.sp,
    color: AppColors.onAccent,
  );

  static TextStyle get splashSubtitle => _dmSans(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.onAccent,
  );

  static TextStyle get cardAmount => _dmSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get amountSymbol => _dmSans(
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get amountHint =>
      amount.copyWith(color: AppColors.onAccentFaint);

  static TextStyle get profileTitle => _dmSans(
    fontSize: 35.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.44.sp,
    height: 1.04,
    color: AppColors.onAccent,
  );

  static TextStyle get code => _dmSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 5.sp,
    color: AppColors.ink,
  );

  // Screen & Card Headings
  static TextStyle get screenTitle => _dmSans(
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static TextStyle get title => _dmSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get dialogTitle => _dmSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get cardTitle => _dmSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get cardTitleWhite => _dmSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get subCardTitle => _dmSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get subHeader => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  // Body & Descriptions
  static TextStyle get subtitle =>
      _dmSans(fontSize: 15.sp, height: 1.45, color: AppColors.onAccentMuted);

  static TextStyle get body =>
      _dmSans(fontSize: 14.sp, height: 1.45, color: AppColors.muted);

  static TextStyle get cardSubtitle =>
      _dmSans(fontSize: 12.sp, height: 1.25, color: AppColors.onAccentMuted);

  static TextStyle get description =>
      _dmSans(fontSize: 12.sp, height: 1.25, color: AppColors.muted);

  static TextStyle get emptyState =>
      _dmSans(fontSize: 14.sp, color: AppColors.muted);

  // Tags & Labels
  static TextStyle get tag => _dmSans(
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );

  static TextStyle get metricTitle => _dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get metricDescription =>
      _dmSans(fontSize: 13.sp, color: AppColors.faint);

  static TextStyle get chartLabel => _dmSans(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get dayLabel => _dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get dayLabelActive => _dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get fieldLabel => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static TextStyle get cardLabel => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get chip => _dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  // Buttons & Links
  static TextStyle get button => _dmSans(
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onAccent,
  );

  static TextStyle get buttonPill => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onPop,
  );

  static TextStyle get buttonAction => _dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static TextStyle get link => _dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.faint,
  );

  // Toggles & Forms
  static TextStyle get toggleTitle => _dmSans(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle get toggleSubtitle =>
      _dmSans(fontSize: 12.sp, height: 1.3, color: AppColors.muted);

  static TextStyle get input => _dmSans(fontSize: 16.sp, color: AppColors.ink);

  static TextStyle get hint => _dmSans(fontSize: 16.sp, color: AppColors.faint);

  // Feedback & Status
  static TextStyle get error => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.error,
  );

  static TextStyle get notice => _dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  static TextStyle get cardHint =>
      _dmSans(fontSize: 13.sp, color: AppColors.onAccentMuted);

  static TextStyle get cardError => _dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onAccentError,
  );
}
