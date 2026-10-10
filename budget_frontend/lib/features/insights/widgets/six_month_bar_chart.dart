import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/features/insights/models/insight_models.dart';
import 'package:budget_frontend/features/insights/widgets/chart_painting.dart';

class SixMonthBarChart extends StatelessWidget {
  const SixMonthBarChart({super.key, required this.records, this.height = 150.0});

  final List<MonthlyRecord> records;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: double.infinity,
      child: CustomPaint(painter: BarChartPainter(records: records)),
    );
  }
}

/// Paired income (In) and expense (Out) bars per month.
class BarChartPainter extends CustomPainter {
  const BarChartPainter({required this.records});

  final List<MonthlyRecord> records;

  static const double topMargin = 8;
  static const double maxBarWidth = 13;
  static const double barGap = 1.5;
  static const double maxBottomRadius = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const left = ChartPainting.leftMargin;
    final chartWidth = size.width - left - ChartPainting.rightMargin;
    final chartHeight = size.height - ChartPainting.bottomMargin - topMargin;
    if (chartWidth <= 0 || chartHeight <= 0 || records.isEmpty) return;

    final maxValue = records.fold<double>(
      1000,
      (max, r) => math.max(max, math.max(r.income, r.expense).toDouble()),
    );
    // Axis top: next half power of ten above the largest bar.
    final halfStep = math.pow(10, (math.log(maxValue) / math.ln10).floor()).toDouble() / 2;
    final topValue = (maxValue / halfStep).ceil() * halfStep;

    double y(double value) => topMargin + chartHeight - value / topValue * chartHeight;
    final baseline = topMargin + chartHeight;

    ChartPainting.drawGrid(canvas, size, levels: [0, topValue / 2, topValue], yOf: y);

    final groupWidth = chartWidth / records.length;
    final barWidth = math.min(maxBarWidth, (groupWidth - 8) / 2);
    final topRadius = Radius.circular(barWidth / 2);
    final bottomRadius = Radius.circular(math.min(barWidth / 2, maxBottomRadius));

    RRect bar(double barX, int value) {
      final top = y(value.toDouble());
      return RRect.fromRectAndCorners(
        Rect.fromLTWH(barX, top, barWidth, math.max(0, baseline - top)),
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: bottomRadius,
        bottomRight: bottomRadius,
      );
    }

    for (final (index, record) in records.indexed) {
      final centerX = left + index * groupWidth + groupWidth / 2;

      final incomeBar = bar(centerX - barWidth - barGap, record.income);
      canvas.drawRRect(incomeBar, Paint()..color = AppColors.pop);
      if (record.isCurrent) {
        canvas.drawRRect(
          incomeBar,
          Paint()
            ..color = AppColors.accent
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke,
        );
      }

      canvas.drawRRect(
        bar(centerX + barGap, record.expense),
        Paint()
          ..color = record.isCurrent ? AppColors.accent : AppColors.accent.withValues(alpha: 0.85),
      );

      ChartPainting.paintText(
        canvas,
        record.month,
        ChartPainting.labelStyle.copyWith(
          color: record.isCurrent ? AppColors.ink : AppColors.faint,
          fontWeight: record.isCurrent ? FontWeight.w700 : FontWeight.w600,
        ),
        (textSize) => Offset(centerX - textSize.width / 2, size.height - textSize.height),
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => !listEquals(oldDelegate.records, records);
}
