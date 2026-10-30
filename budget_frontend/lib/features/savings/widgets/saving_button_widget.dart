import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/dashed_border_painter.dart';
import 'package:budget_frontend/features/savings/widgets/new_goal_bottom_sheet.dart';

class SavingButtonWidget extends StatelessWidget {
  const SavingButtonWidget({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => NewGoalBottomSheet.show(context),
        borderRadius: AppBorderRadius.pill,
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(borderRadius: AppBorderRadius.pill),
          child: CustomPaint(
            painter: DashedBorderPainter(),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.add, color: AppColors.ink, size: 20.sp),
                  8.horizontalSpace,
                  Text('New savings goal', style: AppTextStyle.toggleTitle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef SavingButton = SavingButtonWidget;
