import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class ProfileConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const ProfileConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => ProfileConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return AlertDialog(
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
            child: Icon(icon, color: AppColors.error, size: isTablet ? 20 : 20.sp),
          ),
          SizedBox(width: isTablet ? 12 : 12.w),
          Expanded(
            child: Text(
              title,
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
          message,
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTextStyle.fieldLabel.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
            padding: isTablet
                ? const EdgeInsets.symmetric(horizontal: 18, vertical: 10)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(
            confirmLabel,
            style: AppTextStyle.fieldLabel.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
