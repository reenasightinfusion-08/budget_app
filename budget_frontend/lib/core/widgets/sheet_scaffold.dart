import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/common_loader.dart';
import 'package:budget_frontend/core/widgets/glass_back_button.dart';
import 'package:budget_frontend/core/widgets/sheet_background.dart';
import 'package:budget_frontend/core/widgets/sheet_header.dart';
import 'package:budget_frontend/core/widgets/sheet_surface.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Shared frame for every auth screen: gradient header on top, white sheet
/// below. On mobile it renders a stacked sheet; on tablet (shortestSide >= 600dp)
/// it automatically renders the 2-column split layout matching the design.
/// [child] sits inside the surface and may use a [Spacer] to push a footer.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.isLoading,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    final bool authLoading = context.watch<AuthBloc>().state.isLoading;
    final bool effectiveLoading = isLoading ?? authLoading;
    final bool isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.accent,
        body: Stack(
          children: [
            if (!isTablet) ...[
              // Existing unchanged mobile layout
              const Positioned.fill(child: SheetBackground()),
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: SheetHeader(title: title, subtitle: subtitle, onBack: onBack),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SheetSurface(child: child),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Tablet Two-Column Split Screen layout
              _TabletSplitLayout(
                title: title,
                subtitle: subtitle,
                onBack: onBack,
                child: child,
              ),
            ],
            if (effectiveLoading)
              const Positioned.fill(
                child: CommonLoader(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabletSplitLayout extends StatelessWidget {
  const _TabletSplitLayout({
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
  Widget build(BuildContext context) {
    final String leftTitle;
    final String leftSubtitle;
    final String detailTitle;
    final String detailSubtitle;

    switch (title) {
      case 'Welcome back':
        leftTitle = 'Welcome back\nto Budgie';
        leftSubtitle = 'A calmer way to watch your money.';
        detailTitle = 'Log in';
        detailSubtitle = 'Pick up right where your budget left off.';
        break;
      case 'Create your account':
        leftTitle = 'Start fresh\nwith Budgie';
        leftSubtitle = 'Track spending, plan budgets, and reach your goals.';
        detailTitle = 'Create account';
        detailSubtitle = 'Set up your login to get started.';
        break;
      case 'Hi, I’m Budgie':
        leftTitle = 'Meet Budgie,\nyour money guide';
        leftSubtitle = 'Always watching your pace so you never overspend.';
        detailTitle = 'Quick setup';
        detailSubtitle = 'Two quick answers and I’ll start counting for you.';
        break;
      case 'Forgot password?':
        leftTitle = 'Don’t worry,\nwe’ve got you';
        leftSubtitle = 'We’ll get you back into your account in no time.';
        detailTitle = 'Forgot password';
        detailSubtitle = 'Enter your email and we’ll send you a 6-digit code.';
        break;
      case 'Verify your email':
        leftTitle = 'Check your\ninbox';
        leftSubtitle = 'One last step to confirm your email and secure your account.';
        detailTitle = 'Verify email';
        detailSubtitle = subtitle;
        break;
      case 'Set a new password':
        leftTitle = 'Secure your\naccount';
        leftSubtitle = 'Choose a fresh password you haven’t used before.';
        detailTitle = 'New password';
        detailSubtitle = 'Enter the reset code and pick a new password.';
        break;
      default:
        leftTitle = 'Budgie';
        leftSubtitle = 'A calmer way to watch your money.';
        detailTitle = title;
        detailSubtitle = subtitle;
    }

    return Row(
      children: [
        // Left Column (Hero & Branding - 44% width)
        Expanded(
          flex: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const SheetBackground(),
              // Concentric decorative rings behind mascot
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onBack != null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: GlassBackButton(onPressed: onBack!),
                        ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assest/cartoon.svg',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        leftTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.headline.copyWith(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        leftSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.subtitle.copyWith(
                          fontSize: 16,
                          color: AppColors.onAccentMuted,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right Column (White Surface & Form - 56% width)
        Expanded(
          flex: 56,
          child: Container(
            color: AppColors.surface,
            height: double.infinity,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detailTitle,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyle.fontFamily,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                      letterSpacing: -0.6,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    detailSubtitle,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyle.fontFamily,
                                      fontSize: 15,
                                      color: AppColors.muted,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  Expanded(child: child),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
