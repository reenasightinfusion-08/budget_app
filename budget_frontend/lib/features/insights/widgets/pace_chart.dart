import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/insights/widgets/chart_painting.dart';

class PaceChart extends StatelessWidget {
  const PaceChart({
    super.key,
    required this.budget,
    required this.cumulativeSpending,
    required this.daysInMonth,
    this.height = 160.0,
  });

  final int budget;
  final List<double> cumulativeSpending;
  final int daysInMonth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: double.infinity,
      child: CustomPaint(
        painter: PaceChartPainter(
          budget: budget.toDouble(),
          cumulativeSpending: cumulativeSpending,
          daysInMonth: daysInMonth,
        ),
      ),
    );
  }
}

/// Cumulative spend curve against a dotted even-pace line for the month's budget.
class PaceChartPainter extends CustomPainter {
  const PaceChartPainter({
    required this.budget,
    required this.cumulativeSpending,
    required this.daysInMonth,
  });

  final double budget;
  final List<double> cumulativeSpending;
  final int daysInMonth;

  static const double topMargin = 14;

  @override
  void paint(Canvas canvas, Size size) {
    const left = ChartPainting.leftMargin;
    final chartWidth = size.width - left - ChartPainting.rightMargin;
    final chartHeight = size.height - ChartPainting.bottomMargin - topMargin;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final maxSpent = cumulativeSpending.fold<double>(0, math.max);
    final topValue = math.max(budget, maxSpent) * 1.08;

    double x(int day) =>
        daysInMonth <= 1 ? left : left + (day - 1) / (daysInMonth - 1) * chartWidth;
    double y(double value) =>
        topValue <= 0 ? topMargin + chartHeight : topMargin + chartHeight - value / topValue * chartHeight;

    ChartPainting.drawGrid(canvas, size, levels: [0, budget / 2, budget], yOf: y);
    drawBudgetPace(canvas, x, y);
    if (cumulativeSpending.isNotEmpty) drawSpending(canvas, size, x, y);
    drawDayLabels(canvas, size, x);
  }

  void drawBudgetPace(Canvas canvas, double Function(int) x, double Function(double) y) {
    final end = Offset(x(daysInMonth), y(budget));
    final pacePaint = Paint()
      ..color = AppColors.faint
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    ChartPainting.drawDashedLine(canvas, Offset(x(1), y(0)), end, pacePaint);
    ChartPainting.paintText(
      canvas,
      'Budget pace',
      ChartPainting.labelStyle.copyWith(fontSize: 9.5.sp, color: AppColors.muted),
      (textSize) => Offset(end.dx - textSize.width, end.dy - textSize.height - 4),
    );
  }

  void drawSpending(Canvas canvas, Size size, double Function(int) x, double Function(double) y) {
    final linePath = Path()..moveTo(x(1), y(cumulativeSpending[0]));
    final areaPath = Path()
      ..moveTo(x(1), y(0))
      ..lineTo(x(1), y(cumulativeSpending[0]));

    for (var i = 1; i < cumulativeSpending.length; i++) {
      final previousX = x(i);
      final controlX = previousX + (x(i + 1) - previousX) / 2;
      final previousY = y(cumulativeSpending[i - 1]);
      final currentY = y(cumulativeSpending[i]);
      linePath.cubicTo(controlX, previousY, controlX, currentY, x(i + 1), currentY);
      areaPath.cubicTo(controlX, previousY, controlX, currentY, x(i + 1), currentY);
    }

    final lastX = x(cumulativeSpending.length);
    areaPath
      ..lineTo(lastX, y(0))
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.pop.withValues(alpha: 0.55),
          AppColors.pop.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTRB(ChartPainting.leftMargin, topMargin, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotCenter = Offset(lastX, y(cumulativeSpending.last));
    canvas.drawCircle(dotCenter, 5, Paint()..color = AppColors.pop);
    canvas.drawCircle(
      dotCenter,
      5,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
  }

  void drawDayLabels(Canvas canvas, Size size, double Function(int) x) {
    final month = AppFormatters.monthShort(DateTime.now().month);
    final days = [1, (daysInMonth / 2).round(), daysInMonth];

    for (final (index, day) in days.indexed) {
      ChartPainting.paintText(
        canvas,
        '$month $day',
        ChartPainting.labelStyle,
        (textSize) => Offset(
          switch (index) {
            0 => x(day),
            2 => x(day) - textSize.width,
            _ => x(day) - textSize.width / 2,
          },
          size.height - textSize.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(PaceChartPainter oldDelegate) =>
      oldDelegate.budget != budget ||
      oldDelegate.daysInMonth != daysInMonth ||
      !listEquals(oldDelegate.cumulativeSpending, cumulativeSpending);
}
