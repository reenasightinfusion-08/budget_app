import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:budget_frontend/core/ads/ad_ids.dart';
import 'package:budget_frontend/core/ads/ad_service.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// A native-styled Banner Ad card designed to fit seamlessly into the app's aesthetic.
///
/// Features:
/// - Smooth fade-in animation on load.
/// - Gracefully collapses to [SizedBox.shrink] if loading fails or platform is unsupported.
/// - Subtle "Sponsored" badge adhering to Store guidelines without cluttering the UI.
/// - Safe lifecycle handling and automatic disposal.
class AppAdBanner extends StatefulWidget {
  const AppAdBanner({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.showBadge = true,
  });

  /// Size of the banner ad (defaults to [AdSize.banner] 320x50).
  final AdSize adSize;

  /// Optional outer margin.
  final EdgeInsetsGeometry? margin;

  /// Whether to display a subtle "Sponsored" disclosure tag.
  final bool showBadge;

  @override
  State<AppAdBanner> createState() => _AppAdBannerState();
}

class _AppAdBannerState extends State<AppAdBanner>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailed = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _loadBannerAd();
    AdService.fullScreenDismissedNotifier.addListener(_onFullScreenDismissed);
  }

  @override
  void dispose() {
    AdService.fullScreenDismissedNotifier.removeListener(
      _onFullScreenDismissed,
    );
    _animController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onFullScreenDismissed() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _reloadBannerAd();
      }
    });
  }

  void _reloadBannerAd() {
    if (!mounted || !AdService.supported) return;
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!AdService.supported) {
      setState(() => _hasFailed = true);
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdIds.banner,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _hasFailed = false;
          });
          _animController.forward();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AppAdBanner] Ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _hasFailed = true;
              _bannerAd = null;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFailed || !AdService.supported) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      // Keep invisible or minimal until loaded to avoid layout jumps
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: widget.adSize.width.toDouble() + 24.w,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.tile,
            border: Border.all(
              color: AppColors.line.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.03),
                blurRadius: 12.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showBadge) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fill,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'AD',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.faint,
                        ),
                      ),
                    ),
                  ],
                ),
                4.verticalSpace,
              ],
              SizedBox(
                width: widget.adSize.width.toDouble(),
                height: widget.adSize.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
