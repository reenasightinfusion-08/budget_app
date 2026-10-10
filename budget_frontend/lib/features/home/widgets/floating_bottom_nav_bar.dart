import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/features/home/widgets/nav_bar_item.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}

/// Floating tab bar with a liquid pill. Drag it anywhere along the bar; on
/// release it flows to the nearest tab. The edge facing the destination leaves
/// first and the other edge lags, so the pill stretches like water mid-travel
/// and then settles with a small overshoot.
class FloatingBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<NavItemData> items;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.items = const [
      NavItemData(icon: AppIcons.home, label: 'Home'),
      NavItemData(icon: AppIcons.analytics, label: 'Insights'),
      NavItemData(icon: AppIcons.wallet, label: 'Wallet'),
      NavItemData(icon: AppIcons.savings, label: 'Savings'),
    ],
  });

  @override
  State<FloatingBottomNavBar> createState() => FloatingBottomNavBarState();
}

class FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with TickerProviderStateMixin {
  // The edge heading toward the target is quick; the one it leaves behind is slow.
  // The gap between them is the stretch.
  static const SpringDescription leadingSpring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 24,
  );
  static const SpringDescription trailingSpring = SpringDescription(
    mass: 1,
    stiffness: 150,
    damping: 17,
  );

  // Pill edges in slot units: the pill covers [leftEdge, rightEdge] and rests
  // at [index, index + 1].
  late final AnimationController leftEdge = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );
  late final AnimationController rightEdge = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex + 1.0,
  );

  int hapticIndex = 0;

  int get maxIndex => widget.items.length - 1;

  double get center => (leftEdge.value + rightEdge.value - 1) / 2;

  @override
  void initState() {
    super.initState();
    hapticIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(FloatingBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        center.round() != widget.selectedIndex) {
      snapTo(widget.selectedIndex, notify: false);
    }
  }

  @override
  void dispose() {
    leftEdge.dispose();
    rightEdge.dispose();
    super.dispose();
  }

  void snapTo(int index, {bool notify = true, double velocity = 0}) {
    final movingRight = index >= center;
    final leftSpring = movingRight ? trailingSpring : leadingSpring;
    final rightSpring = movingRight ? leadingSpring : trailingSpring;

    leftEdge.animateWith(
      SpringSimulation(leftSpring, leftEdge.value, index.toDouble(), velocity),
    );
    rightEdge.animateWith(
      SpringSimulation(rightSpring, rightEdge.value, index + 1.0, velocity),
    );

    hapticIndex = index;
    if (notify && index != widget.selectedIndex) widget.onTabSelected(index);
  }

  void onDragStart(DragStartDetails details) {
    leftEdge.stop();
    rightEdge.stop();
  }

  void onDragUpdate(DragUpdateDetails details, double slotWidth) {
    final next = (center + details.delta.dx / slotWidth).clamp(
      0.0,
      maxIndex.toDouble(),
    );
    leftEdge.value = next;
    rightEdge.value = next + 1;

    final nearest = next.round();
    if (nearest != hapticIndex) {
      hapticIndex = nearest;
      HapticFeedback.selectionClick();
    }
  }

  void onDragEnd(DragEndDetails details, double slotWidth) {
    final velocity = (details.primaryVelocity ?? 0) / slotWidth;
    final target = (center + velocity * 0.12).round().clamp(0, maxIndex);
    snapTo(target, velocity: velocity);
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 64.h,
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(36.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.08),
          blurRadius: 24.r,
          offset: Offset(0, 8.h),
        ),
        BoxShadow(
          color: AppColors.cardShadow.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 2.h),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / widget.items.length;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: onDragStart,
          onHorizontalDragUpdate: (details) => onDragUpdate(details, slotWidth),
          onHorizontalDragEnd: (details) => onDragEnd(details, slotWidth),
          child: AnimatedBuilder(
            animation: Listenable.merge([leftEdge, rightEdge]),
            builder: (context, _) {
              final left = leftEdge.value;
              final right = math.max(rightEdge.value, left + 0.6);
              final middle = center;

              final stretch = (right - left - 1).abs().clamp(0.0, 1.0);
              final lift = 5.h * stretch;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: left * slotWidth - lift,
                    width: (right - left) * slotWidth + lift * 2,
                    top: -lift,
                    bottom: -lift,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.95),
                            AppColors.fill,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32.r),
                        border: Border.all(
                          color: AppColors.surface.withValues(
                            alpha: 0.9 * stretch,
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(
                              alpha: 0.22 * stretch,
                            ),
                            blurRadius: 18.r * stretch,
                            offset: Offset(0, 6.h * stretch),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var index = 0; index < widget.items.length; index++)
                        Expanded(
                          child: NavBarItem(
                            data: widget.items[index],
                            proximity: (1 - (middle - index).abs()).clamp(
                              0.0,
                              1.0,
                            ),
                            onTap: () => snapTo(index),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    ),
  );
}
