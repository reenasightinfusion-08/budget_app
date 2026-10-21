import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';

/// Continuous audio waveform line with smooth undulating middle wave peaks.
class AudioWaveformWidget extends StatefulWidget {
  const AudioWaveformWidget({
    super.key,
    this.color = AppColors.popDeep,
    this.height,
  });

  final Color color;
  final double? height;

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        height: widget.height ?? 38.h,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: _AudioWaveformLinePainter(
                color: widget.color,
                animationValue: _animController.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AudioWaveformLinePainter extends CustomPainter {
  const _AudioWaveformLinePainter({
    this.color = AppColors.popDeep,
    required this.animationValue,
  });

  final Color color;
  final double animationValue;

  static const List<Offset> _points = [
    Offset(0.00, 0.00),
    Offset(0.12, 0.00),
    Offset(0.14, -0.20),
    Offset(0.16, 0.35),
    Offset(0.18, -0.55),
    Offset(0.20, 0.80),
    Offset(0.22, -0.95),
    Offset(0.24, 0.90),
    Offset(0.26, -0.70),
    Offset(0.28, 0.45),
    Offset(0.30, -0.30),
    Offset(0.32, 0.20),
    Offset(0.34, -0.45),
    Offset(0.36, 0.75),
    Offset(0.38, -0.85),
    Offset(0.40, 0.90),
    Offset(0.42, -0.70),
    Offset(0.44, 0.50),
    Offset(0.46, -0.35),
    Offset(0.48, 0.25),
    Offset(0.50, -0.30),
    Offset(0.52, 0.60),
    Offset(0.54, -0.80),
    Offset(0.56, 0.95),
    Offset(0.58, -0.90),
    Offset(0.60, 0.85),
    Offset(0.62, -0.65),
    Offset(0.64, 0.40),
    Offset(0.66, -0.25),
    Offset(0.68, 0.55),
    Offset(0.70, -0.75),
    Offset(0.72, 0.90),
    Offset(0.74, -0.85),
    Offset(0.76, 0.65),
    Offset(0.78, -0.40),
    Offset(0.80, 0.20),
    Offset(0.82, -0.10),
    Offset(0.85, 0.00),
    Offset(1.00, 0.00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;
    final maxAmp = size.height * 0.44;
    path.moveTo(0, midY);

    for (int i = 0; i < _points.length - 1; i++) {
      final p1Base = _points[i];
      final p2Base = _points[i + 1];

      // Flat tails (dy == 0) remain strictly stationary on the baseline.
      final factor1 = p1Base.dy == 0
          ? 0.0
          : (0.70 + 0.30 * math.sin(2 * math.pi * animationValue + i * 0.35));
      final factor2 = p2Base.dy == 0
          ? 0.0
          : (0.70 +
              0.30 *
                  math.sin(2 * math.pi * animationValue + (i + 1) * 0.35));

      final dy1 = p1Base.dy * factor1;
      final dy2 = p2Base.dy * factor2;

      final p1 = Offset(p1Base.dx * w, midY + dy1 * maxAmp);
      final p2 = Offset(p2Base.dx * w, midY + dy2 * maxAmp);

      final cx = (p1.dx + p2.dx) / 2;
      path.cubicTo(cx, p1.dy, cx, p2.dy, p2.dx, p2.dy);
    }

    path.lineTo(w, midY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformLinePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}
