import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/widgets/sheet_background.dart';
import 'package:budget_frontend/core/widgets/sheet_header.dart';
import 'package:budget_frontend/core/widgets/sheet_surface.dart';

/// Shared frame for every auth screen: gradient header on top, white sheet
/// below. [child] sits inside the sheet and may use a [Spacer] to push a
/// footer to the bottom.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: AppColors.accent,
          body: Stack(
            children: [
              const Positioned.fill(child: SheetBackground()),
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: IntrinsicHeight( 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SheetHeader(title: title, subtitle: subtitle, onBack: onBack),
                            Expanded(child: SheetSurface(child: child)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
