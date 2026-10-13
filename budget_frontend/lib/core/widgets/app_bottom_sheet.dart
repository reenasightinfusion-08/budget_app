import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// Common non-scrollable bottom sheet with rounded corners, drag handle,
/// close button, and customizable title widget.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.onClose,
    required this.child,
  });

  final Widget? title;
  final VoidCallback? onClose;
  final Widget child;

  /// Convenience method to open this bottom sheet smoothly anywhere.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    VoidCallback? onClose,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
     barrierColor: Color(0xFF101A2B).withValues(alpha: 0.5),
      builder: (sheetContext) => AppBottomSheet(
        title: title,
        onClose: onClose,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: AppBorderRadius.sheet,
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + bottomPadding),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              12.verticalSpace,
              Row(
                children: [
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      radius: 23.r,
                      backgroundColor: AppColors.surface,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.ink,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  if (title != null) ...[
                    Expanded(
                      child: Center(
                        child: title!,
                      ),
                    ),
                    SizedBox(width: 46.r),
                  ],
                ],
              ),
              16.verticalSpace,
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CommonBottomSheet = AppBottomSheet;
