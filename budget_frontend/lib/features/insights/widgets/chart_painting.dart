import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

/// Drawing helpers and plot-area insets shared by the insights chart painters.
class ChartPainting {
  const ChartPainting._();

  static const double leftMargin = 38;
  static const double rightMargin = 8;
  static const double bottomMargin = 22;

  static TextStyle get labelStyle => TextStyle(
    color: AppColors.faint,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'DM Sans',
  );

  /// Paints [text] with its top-left corner at [anchor], which receives the measured text size.
  static void paintText(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset Function(Size textSize) anchor,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, anchor(painter.size));
    painter.dispose();
  }

  /// Horizontal grid lines at [levels], each labelled on the left in compact rupees.
  static void drawGrid(
    Canvas canvas,
    Size size, {
    required List<double> levels,
    required double Function(double value) yOf,
  }) {
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1.0;

    for (final level in levels) {
      final y = yOf(level);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), gridPaint);
      paintText(
        canvas,
        AppFormatters.compactRupees(level),
        labelStyle,
        (textSize) => Offset(leftMargin - textSize.width - 6, y - textSize.height / 2),
      );
    }
  }

  static void drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(to.dx, to.dy);

    for (final metric in path.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += dash + gap) {
        canvas.drawPath(metric.extractPath(start, math.min(start + dash, metric.length)), paint);
      }
    }
  }
}
