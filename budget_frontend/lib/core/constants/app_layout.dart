import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLayout {
  const AppLayout._();

  /// Bottom space tab screens reserve so content scrolls clear of the floating nav bar.
  static const double navBarClearance = 110;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Distance from the screen bottom to the floating nav bar, safely clearing
  /// iOS home indicators and Android system bars.
  static double navBarBottom(BuildContext context) =>
      16.h + MediaQuery.paddingOf(context).bottom;

  /// Distance from the screen bottom to the add button, always above the nav bar.
  static double fabBottom(BuildContext context) =>
      navBarBottom(context) + 64.h + 14.h;

  /// Bottom padding for tab content so it scrolls clear of the nav bar and safe area.
  static double navBarClearanceOf(BuildContext context) =>
      navBarClearance.h + MediaQuery.paddingOf(context).bottom;

  /// Whether the current device is a tablet (shortest side >= 600dp).
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  /// Maximum content width on tablets so content doesn't stretch awkwardly in landscape.
  static const double maxContentWidth = 1040.0;
}
