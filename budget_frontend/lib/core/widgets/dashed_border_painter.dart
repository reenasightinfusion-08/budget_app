import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

/// A reusable [CustomPainter] that draws a dashed/dotted rounded border
/// around any given rectangle with specified [radius], [color], and dash metrics.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    this.color = AppColors.faint,
    this.radius = const Radius.circular(20),
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashGap = 3.0,
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
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

typedef AppDashedBorderPainter = DashedBorderPainter;
