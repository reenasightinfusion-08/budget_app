import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:budget_frontend/core/ads/ad_ids.dart';
import 'package:budget_frontend/core/ads/ad_service.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// Native Ad card rendering Google Mobile Ads Native Templates (small or medium).
/// Styled with the Budgie design tokens for native feel in lists and dashboards.
class NativeAdWidget extends StatefulWidget {
  final TemplateType templateType;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const NativeAdWidget({
    super.key,
    this.templateType = TemplateType.medium,
    this.height,
    this.margin,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdService.supported) return;

    _ad = NativeAd(
      adUnitId: AdIds.native,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: AppColors.surface,
        cornerRadius: 18,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.accent,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.ink,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.muted,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.faint,
          size: 12,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, e) {
          debugPrint('[NativeAdWidget] Failed: $e');
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();

    final isSmall = widget.templateType == TemplateType.small;
    final contentHeight = widget.height ?? (isSmall ? 95.0 : 355.0);

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.h),
      height: contentHeight + 4,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
