import 'dart:math';

import 'package:flutter/material.dart';

/// Rotates a left-to-right gradient to a CSS-style angle, so a gradient looks
/// the same on a wide button as `linear-gradient(<angle>deg, ...)` does on the web.
class CssAngleGradientTransform extends GradientTransform {
  const CssAngleGradientTransform(this.degrees);

  final double degrees;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final radians = degrees * pi / 180;
    final length = bounds.width * sin(radians).abs() + bounds.height * cos(radians).abs();
    final center = bounds.center;
    return Matrix4.translationValues(center.dx, center.dy, 0)
        .multiplied(Matrix4.rotationZ(radians - pi / 2))
        .multiplied(Matrix4.diagonal3Values(length / bounds.width, 1, 1))
        .multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
  }
}

class AppGradients {
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5F85B7), Color(0xFF2C5FA0)],
    transform: CssAngleGradientTransform(140),
  );

  static const LinearGradient header = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5F85B7), Color(0xFF2C5FA0), Color(0xFF1E416D)],
    stops: [0, 0.46, 1],
    transform: CssAngleGradientTransform(165),
  );

  static const LinearGradient moneyCard = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF567FB3), Color(0xFF2C5FA0), Color(0xFF224A7D)],
    stops: [0, 0.52, 1],
    transform: CssAngleGradientTransform(145),
  );

  static const RadialGradient moneyCardGlow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.1,
    colors: [Color(0x29FFFFFF), Color(0x00FFFFFF)],
    stops: [0, 0.55],
  );

  static const RadialGradient headerGlowTopRight = RadialGradient(
    center: Alignment.topRight,
    radius: 0.9,
    colors: [Color(0x38FFFFFF), Color(0x00FFFFFF)],
    stops: [0, 0.6],
  );

  static const RadialGradient headerGlowBottomLeft = RadialGradient(
    center: Alignment.bottomLeft,
    radius: 0.8,
    colors: [Color(0x3DA9CBF7), Color(0x00A9CBF7)],
    stops: [0, 0.7],
  );
}
