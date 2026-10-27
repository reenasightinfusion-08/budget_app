import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_frontend/core/ads/ad_service.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';

/// "Watch an ad to unlock for 24h" gate matching the manifest-app pattern.
/// Never blocks the user when ads are unsupported or none is ready.
class AdGate {
  static const _validFor = Duration(hours: 24);

  static Future<bool> isUnlocked(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final at = prefs.getInt('ad_gate_$key');
      if (at == null) return false;
      return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(at)) <
          _validFor;
    } catch (_) {
      return false;
    }
  }

  static Future<void> unlock(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ad_gate_$key', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  static Future<void> run(
    BuildContext context, {
    required String key,
    required String title,
    required String message,
    required VoidCallback onUnlocked,
    bool interstitialStyle = false,
    bool blocking = true,
  }) async {
    final ready = interstitialStyle
        ? AdService.rewardedInterstitialReady
        : AdService.rewardedReady;

    if (!AdService.supported || !ready || await isUnlocked(key)) {
      onUnlocked();
      return;
    }
    if (!context.mounted) return;

    final watch = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Watch ad',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (watch != true) {
      if (!blocking) onUnlocked();
      return;
    }

    var earned = false;
    void onReward(_) => earned = true;
    void onClosed() {
      if (!earned) {
        if (!blocking) onUnlocked();
        return;
      }
      unlock(key);
      onUnlocked();
    }

    final shown = interstitialStyle
        ? AdService.showRewardedInterstitial(onReward: onReward, onClosed: onClosed)
        : AdService.showRewarded(onReward: onReward, onClosed: onClosed);

    if (!shown) onUnlocked();
  }
}
