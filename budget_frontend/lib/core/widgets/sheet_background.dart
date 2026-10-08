import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_gradients.dart';

class SheetBackground extends StatelessWidget {
  const SheetBackground({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.header)),
          DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.headerGlowTopRight)),
          DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.headerGlowBottomLeft)),
        ],
      );
}
