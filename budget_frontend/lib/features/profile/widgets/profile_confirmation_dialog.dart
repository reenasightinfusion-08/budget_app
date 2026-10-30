import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class ProfileConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool showLoader;

  const ProfileConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
    required this.onConfirm,
    this.showLoader = true,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool showLoader = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ProfileConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        showLoader: showLoader,
      ),
    );
  }

  @override
  State<ProfileConfirmationDialog> createState() =>
      _ProfileConfirmationDialogState();
}

class _ProfileConfirmationDialogState extends State<ProfileConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    if (widget.showLoader) {
      setState(() => _isLoading = true);
      // Display loader for a moment so the user sees clear visual feedback
      await Future.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
    }

    Navigator.of(context).pop();
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 40 : 24.w,
          vertical: isTablet ? 40 : 24.h,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 8.r),
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: AppColors.error,
                size: isTablet ? 20 : 20.sp,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 12.w),
            Expanded(
              child: Text(
                widget.title,
                style: AppTextStyle.title.copyWith(
                  fontSize: isTablet ? 18 : 18.sp,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 380 : 330),
          child: Text(
            widget.message,
            style: AppTextStyle.body.copyWith(
              color: AppColors.muted,
              fontSize: isTablet ? 14 : 14.sp,
            ),
          ),
        ),
        actionsPadding: isTablet
            ? const EdgeInsets.fromLTRB(20, 0, 20, 18)
            : EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyle.fieldLabel.copyWith(
                color: _isLoading
                    ? AppColors.muted.withValues(alpha: 0.4)
                    : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.error.withValues(alpha: 0.75),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
              padding: isTablet
                  ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
                  : EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            onPressed: _isLoading ? null : _handleConfirm,
            child: _isLoading
                ? SizedBox(
                    width: isTablet ? 18 : 18.r,
                    height: isTablet ? 18 : 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.confirmLabel,
                    style: AppTextStyle.fieldLabel.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
