import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// A reusable pill toast matching the app design system with smooth slide & fade animations.
class AppToast {
  static OverlayEntry? _currentEntry;
  static _AppToastAnimationState? _currentState;

  /// Shows the toast across the screen via [OverlayEntry].
  ///
  /// Any existing toast is smoothly dismissed before the new one is shown.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(milliseconds: 2800),
    Color? backgroundColor,
    Color? textColor,
    Color? dotColor,
    bool showDot = false,
    Widget? leading,
    double? bottom,
    VoidCallback? onTap,
    VoidCallback? onDismissed,
  }) {
    // Dismiss any previously showing toast
    dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlayWrapper(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor ?? AppColors.accent,
        textColor: textColor ?? AppColors.onAccent,
        dotColor: dotColor ?? AppColors.pop,
        showDot: showDot,
        leading: leading,
        bottom: bottom ?? 100.h,
        onTap: () {
          onTap?.call();
          dismiss();
        },
        onDismissed: () {
          if (_currentEntry == entry) {
            _currentEntry = null;
            _currentState = null;
          }
          entry.remove();
          onDismissed?.call();
        },
        onStateCreated: (state) {
          _currentState = state;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Manually dismisses the currently visible toast with reverse animation.
  static void dismiss() {
    if (_currentState != null) {
      _currentState?.dismiss();
      _currentState = null;
    } else if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }
  }
}

/// Overlay wrapper handling entrance, wait duration, and exit animation
class _ToastOverlayWrapper extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Color textColor;
  final Color dotColor;
  final bool showDot;
  final Widget? leading;
  final double bottom;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final ValueChanged<_AppToastAnimationState> onStateCreated;

  const _ToastOverlayWrapper({
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.textColor,
    required this.dotColor,
    required this.showDot,
    this.leading,
    required this.bottom,
    required this.onTap,
    required this.onDismissed,
    required this.onStateCreated,
  });

  @override
  State<_ToastOverlayWrapper> createState() => _AppToastAnimationState();
}

class _AppToastAnimationState extends State<_ToastOverlayWrapper>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _exitController;

  late final Animation<double> _enterFade;
  late final Animation<double> _enterScale;
  late final Animation<double> _enterSlideY;

  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitSlideY;

  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Entrance: fades in quickly
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Subtle scale pop on enter
    _enterScale = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutBack,
    ));

    // Y comes down from UPWARD (-0.75) to resting position (0.0)
    _enterSlideY = Tween<double>(
      begin: -0.75,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutBack,
    ));

    // Exit: slides DOWNWARD (0.0 -> 0.75)
    _exitSlideY = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    ));

    _exitScale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    ));

    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeIn),
    ));

    _enterController.forward().then((_) {
      if (mounted) {
        _dismissTimer = Timer(widget.duration, () {
          dismiss();
        });
      }
    });
  }

  void dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    if (mounted) {
      _exitController.forward().then((_) {
        widget.onDismissed();
      });
    } else {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _enterController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottom,
      child: SafeArea(
        top: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: Listenable.merge([_enterController, _exitController]),
              builder: (context, child) {
                final double currentY = _enterSlideY.value + _exitSlideY.value;
                final double currentFade = (_enterFade.value * _exitFade.value).clamp(0.0, 1.0);
                final double currentScale = _enterScale.value * _exitScale.value;

                return FractionalTranslation(
                  translation: Offset(0.0, currentY),
                  child: Opacity(
                    opacity: currentFade,
                    child: Transform.scale(
                      scale: currentScale,
                      child: child,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.opaque,
                child: AppToastWidget(
                  message: widget.message,
                  backgroundColor: widget.backgroundColor,
                  textColor: widget.textColor,
                  dotColor: widget.dotColor,
                  showDot: widget.showDot,
                  leading: widget.leading,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone visual toast pill widget that can be used directly in layouts or overlays.
class AppToastWidget extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? dotColor;
  final bool showDot;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const AppToastWidget({
    super.key,
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.dotColor,
    this.showDot = false,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.accent;
    final effectiveTextColor = textColor ?? AppColors.onAccent;
    final effectiveDotColor = dotColor ?? AppColors.pop;

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: AppBorderRadius.pill,
        boxShadow: [
          BoxShadow(
            color: effectiveBgColor.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 8.w),
          ] else if (showDot) ...[
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: effectiveDotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
