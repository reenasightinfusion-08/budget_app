import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
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
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.pill,
          ),
          child: CustomPaint(
            painter: _DashedPillBorderPainter(
              color: AppColors.faint,
              radius: AppBorderRadius.pill.topLeft,
              strokeWidth: 1.0,
              dashWidth: 3.0,
              dashGap: 2.5,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.add,
                    color: AppColors.ink,
                    size: 20.sp,
                  ),
                  8.horizontalSpace,
                  Text(
                    'New savings goal',
                    style: AppTextStyle.toggleTitle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedPillBorderPainter extends CustomPainter {
  const _DashedPillBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.0,
    this.dashWidth = 3.0,
    this.dashGap = 2.5,
  });

  final Color color;
  final Radius radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, radius);
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPillBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

typedef SavingButton = SavingButtonWidget;
