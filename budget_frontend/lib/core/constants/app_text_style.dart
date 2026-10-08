import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

class AppTextStyle {
  static TextStyle get headline => GoogleFonts.outfit(
        fontSize: 36.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.44.sp,
        height: 1.04,
        color: AppColors.onAccent,
      );

  static TextStyle get title => GoogleFonts.outfit(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get code => GoogleFonts.outfit(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 5.sp,
        color: AppColors.ink,
      );

  static TextStyle get subtitle => GoogleFonts.dmSans(
        fontSize: 15.sp,
        height: 1.45,
        color: AppColors.onAccentMuted,
      );

  static TextStyle get input => GoogleFonts.dmSans(
        fontSize: 16.sp,
        color: AppColors.ink,
      );

  static TextStyle get hint => GoogleFonts.dmSans(
        fontSize: 16.sp,
        color: AppColors.faint,
      );

  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onAccent,
      );

  static TextStyle get link => GoogleFonts.dmSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.faint,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 14.sp,
        height: 1.45,
        color: AppColors.muted,
      );

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

  static TextStyle get fieldLabel => GoogleFonts.dmSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );

  static TextStyle get amount => GoogleFonts.outfit(
        fontSize: 48.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.16.sp,
        height: 1.1,
        color: AppColors.onAccent,
      );

  static TextStyle get amountHint => amount.copyWith(color: AppColors.onAccentFaint);

  static TextStyle get amountSymbol => GoogleFonts.outfit(
        fontSize: 30.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onAccentMuted,
      );

  static TextStyle get cardLabel => GoogleFonts.dmSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onAccentMuted,
      );

  static TextStyle get cardHint => GoogleFonts.dmSans(
        fontSize: 13.sp,
        color: AppColors.onAccentMuted,
      );

  static TextStyle get cardError => GoogleFonts.dmSans(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onAccentError,
      );

  static TextStyle get chip => GoogleFonts.dmSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get toggleTitle => GoogleFonts.dmSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get toggleSubtitle => GoogleFonts.dmSans(
        fontSize: 12.sp,
        height: 1.3,
        color: AppColors.muted,
      );
}
