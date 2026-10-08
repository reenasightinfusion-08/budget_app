import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 2.w),
          child: Text(label, style: AppTextStyle.link),
        ),
      );
}
