import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLayout {
  const AppLayout._();

  /// Bottom space tab screens reserve so content scrolls clear of the floating nav bar.
  static const double navBarClearance = 110;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Distance from the screen bottom to the floating nav bar. On iOS the tab
  /// content runs to the screen edge, so the bar uses the same fixed margin
  /// Android shows.
  static double navBarBottom(BuildContext context) =>
      isIOS ? 16.h : 16.h + MediaQuery.paddingOf(context).bottom;

  /// Distance from the screen bottom to the add button, always above the nav bar.
  static double fabBottom(BuildContext context) =>
      navBarBottom(context) + 64.h + 14.h;

  /// Bottom padding for tab content so it scrolls clear of the nav bar.
  static double navBarClearanceOf(BuildContext context) => navBarClearance.h;
}
