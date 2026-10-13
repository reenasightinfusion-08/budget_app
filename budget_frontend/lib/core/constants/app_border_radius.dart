import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBorderRadius {
  static BorderRadius get pill => BorderRadius.circular(999.r);
  static BorderRadius get tile => BorderRadius.circular(22.r);
  static BorderRadius get card => BorderRadius.circular(30.r);
  static BorderRadius get sm => BorderRadius.circular(18.r);
  static BorderRadius get md => BorderRadius.circular(20.r);
  static BorderRadius get lg => BorderRadius.circular(31.r);
  static BorderRadius get sheet => BorderRadius.vertical(top: Radius.circular(40.r));

  // Additional design radii used across the app
  static BorderRadius get indicator => BorderRadius.circular(1.r);
  static BorderRadius get bar => BorderRadius.circular(4.r);
  static BorderRadius get track => BorderRadius.circular(10.r);
  static BorderRadius get xs => BorderRadius.circular(12.r);
  static BorderRadius get chip => BorderRadius.circular(14.r);
  static BorderRadius get dialogInput => BorderRadius.circular(16.r);
  static BorderRadius get dialog => BorderRadius.circular(24.r);
  static BorderRadius get navItem => BorderRadius.circular(32.r);
  static BorderRadius get navBar => BorderRadius.circular(36.r);
}
