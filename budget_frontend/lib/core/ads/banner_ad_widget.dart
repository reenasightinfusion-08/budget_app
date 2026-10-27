import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:budget_frontend/core/ads/ad_ids.dart';
import 'package:budget_frontend/core/ads/ad_service.dart';

/// Anchored adaptive banner ad that sizes itself dynamically to the screen width.
/// Perfect for bottom navigation safe-areas or pinned headers/footers.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  int? _loadedWidth;

  Future<void> _load(int width) async {
    _loadedWidth = width;
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    _ad?.dispose();
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, e) {
          debugPrint('[BannerAdWidget] Failed: $e');
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
    if (!AdService.supported) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_loadedWidth != width) _load(width);
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
