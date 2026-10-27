import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Google's official test ad units (matching the manifest-app configuration).
/// Replace with your real AdMob unit IDs before release.
class AdIds {
  AdIds._();

  static bool get _android => !kIsWeb && Platform.isAndroid;

  /// Set to true to use production AdMob IDs.
  static const bool isProduction = false;

  // ---------------------------------------------------------------------------
  // Production Ad Unit IDs (Paste your live IDs here)
  // ---------------------------------------------------------------------------
  static const String _androidProdBanner = '';
  static const String _iosProdBanner = '';

  static const String _androidProdInterstitial = '';
  static const String _iosProdInterstitial = '';

  static const String _androidProdRewarded = '';
  static const String _iosProdRewarded = '';

  static const String _androidProdRewardedInterstitial = '';
  static const String _iosProdRewardedInterstitial = '';

  static const String _androidProdNative = '';
  static const String _iosProdNative = '';

  static const String _androidProdAppOpen = '';
  static const String _iosProdAppOpen = '';

  // ---------------------------------------------------------------------------
  // Active Ad Unit IDs (Test or Production)
  // ---------------------------------------------------------------------------
  static String get banner {
    if (isProduction) return _android ? _androidProdBanner : _iosProdBanner;
    return _android
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174';
  }

  static String get interstitial {
    if (isProduction) return _android ? _androidProdInterstitial : _iosProdInterstitial;
    return _android
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
  }

  static String get rewarded {
    if (isProduction) return _android ? _androidProdRewarded : _iosProdRewarded;
    return _android
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
  }

  static String get rewardedInterstitial {
    if (isProduction) return _android ? _androidProdRewardedInterstitial : _iosProdRewardedInterstitial;
    return _android
        ? 'ca-app-pub-3940256099942544/5354046379'
        : 'ca-app-pub-3940256099942544/6978759866';
  }

  static String get native {
    if (isProduction) return _android ? _androidProdNative : _iosProdNative;
    return _android
        ? 'ca-app-pub-3940256099942544/2247696110'
        : 'ca-app-pub-3940256099942544/3986624511';
  }

  static String get appOpen {
    if (isProduction) return _android ? _androidProdAppOpen : _iosProdAppOpen;
    return _android
        ? 'ca-app-pub-3940256099942544/9257395921'
        : 'ca-app-pub-3940256099942544/5575463023';
  }
}
