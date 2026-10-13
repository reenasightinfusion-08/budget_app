import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

class AppTextStyle {
  // Display & Amounts
  static TextStyle get amount => GoogleFonts.dmSans(
    fontSize: 48.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.16.sp,
    height: 1.1,
    color: AppColors.onAccent,
  );

  static TextStyle get headline => GoogleFonts.dmSans(
    fontSize: 36.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.44.sp,
    height: 1.04,
    color: AppColors.onAccent,
  );

  static TextStyle get cardAmount => GoogleFonts.dmSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get amountSymbol => GoogleFonts.dmSans(
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get amountHint =>
      amount.copyWith(color: AppColors.onAccentFaint);

  static TextStyle get profileTitle => GoogleFonts.dmSans(
    fontSize: 35.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.44.sp,
    height: 1.04,
    color: AppColors.onAccent,
  );

  static TextStyle get code => GoogleFonts.dmSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 5.sp,
    color: AppColors.ink,
  );

  // Screen & Card Headings
  static TextStyle get screenTitle => GoogleFonts.dmSans(
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static TextStyle get title => GoogleFonts.dmSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get dialogTitle => GoogleFonts.dmSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get cardTitle => GoogleFonts.dmSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get cardTitleWhite => GoogleFonts.dmSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get subCardTitle => GoogleFonts.dmSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get subHeader => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  // Body & Descriptions
  static TextStyle get subtitle => GoogleFonts.dmSans(
    fontSize: 15.sp,
    height: 1.45,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get body =>
      GoogleFonts.dmSans(fontSize: 14.sp, height: 1.45, color: AppColors.muted);

  static TextStyle get cardSubtitle => GoogleFonts.dmSans(
    fontSize: 12.sp,
    height: 1.25,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get description => GoogleFonts.dmSans(
    fontSize: 12.sp,
    height: 1.25,
    color: AppColors.muted,
  );

  static TextStyle get emptyState => GoogleFonts.dmSans(
    fontSize: 14.sp,
    color: AppColors.muted,
  );

  // Tags & Labels
  static TextStyle get tag => GoogleFonts.dmSans(
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );

  static TextStyle get metricTitle => GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get metricDescription => GoogleFonts.dmSans(
    fontSize: 13.sp,
    color: AppColors.faint,
  );

  static TextStyle get chartLabel => GoogleFonts.dmSans(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get dayLabel => GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );

  static TextStyle get dayLabelActive => GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get fieldLabel => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static TextStyle get cardLabel => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.onAccentMuted,
  );

  static TextStyle get chip => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  // Buttons & Links
  static TextStyle get button => GoogleFonts.dmSans(
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onAccent,
  );

  static TextStyle get buttonPill => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.onPop,
  );

  static TextStyle get buttonAction => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static TextStyle get link => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.faint,
  );

  // Toggles & Forms
  static TextStyle get toggleTitle => GoogleFonts.dmSans(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle get toggleSubtitle =>
      GoogleFonts.dmSans(fontSize: 12.sp, height: 1.3, color: AppColors.muted);

  static TextStyle get input =>
      GoogleFonts.dmSans(fontSize: 16.sp, color: AppColors.ink);

  static TextStyle get hint =>
      GoogleFonts.dmSans(fontSize: 16.sp, color: AppColors.faint);

  // Feedback & Status
  static TextStyle get error => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.error,
  );

  static TextStyle get notice => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  static TextStyle get cardHint =>
      GoogleFonts.dmSans(fontSize: 13.sp, color: AppColors.onAccentMuted);

  static TextStyle get cardError => GoogleFonts.dmSans(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.onAccentError,
  );
}
