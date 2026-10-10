import 'package:flutter/material.dart';

/// Keeps every tab alive but fades and slides only the active one in.
class TabPageTransition extends StatelessWidget {
  const TabPageTransition({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < children.length; i++)
            AnimatedSlide(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              offset: Offset(i == index ? 0 : (i < index ? -0.06 : 0.06), 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                opacity: i == index ? 1 : 0,
                child: IgnorePointer(
                  ignoring: i != index,
                  child: TickerMode(enabled: i == index, child: children[i]),
                ),
              ),
            ),
        ],
      );
}
