import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key, required this.onChangeBudget});

  final VoidCallback onChangeBudget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Budget', style: AppTextStyle.screenTitle),
        GestureDetector(
          onTap: onChangeBudget,
          child: AppCard(
            width: 46.r,
            height: 46.r,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
            blur: 10,
            offsetY: 3,
            child: Icon(AppIcons.filter, color: AppColors.accent, size: 20.sp),
          ),
        ),
      ],
    );
  }
}
