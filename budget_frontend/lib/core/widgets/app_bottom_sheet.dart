import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';

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
    final isTablet = AppLayout.isTablet(context);

    if (isTablet) {
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        barrierColor: AppColors.ink.withValues(alpha: 0.5),
        builder: (dialogContext) => _TabletBottomSheetDialog(
          title: title,
          onClose: onClose,
          child: child,
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.ink.withValues(alpha: 0.5),
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
                    borderRadius: AppBorderRadius.pill,
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
                        AppIcons.close,
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

class _TabletBottomSheetDialog extends StatelessWidget {
  const _TabletBottomSheetDialog({
    this.title,
    this.onClose,
    required this.child,
  });

  final Widget? title;
  final VoidCallback? onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.16),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onClose ?? () => Navigator.of(context).pop(),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surface,
                              child: const Icon(
                                AppIcons.close,
                                color: AppColors.ink,
                                size: 20,
                              ),
                            ),
                          ),
                          if (title != null) ...[
                            Expanded(
                              child: Center(
                                child: title!,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
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
            ),
          ),
        ),
      ),
    );
  }
}

typedef CommonBottomSheet = AppBottomSheet;
