import 'package:flutter/foundation.dart';

/// Central place for AdMob ad unit IDs.
///
/// During development, we use Google-provided TEST ad unit IDs to avoid
/// accidental policy violations / invalid traffic.
///
/// In release builds, we use your real AdMob IDs, optionally overridden by
/// Firestore remote config (see `lib/providers/ads_provider.dart`).
class AdMobIds {
  AdMobIds._();

  // Google TEST IDs (safe for development)
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // Your production IDs
  static const String defaultProdBanner =
      'ca-app-pub-7138268980308783/4668697619';
  static const String defaultProdInterstitial =
      'ca-app-pub-7138268980308783/1040443792';
  // Add your prod rewarded ID here later if you want a code fallback.
  static const String defaultProdRewarded = testRewarded;

  /// Fallback banner ID when you don't use remote config providers.
  static String get banner => kReleaseMode ? defaultProdBanner : testBanner;

  /// Fallback interstitial ID when you don't use remote config providers.
  static String get interstitial =>
      kReleaseMode ? defaultProdInterstitial : testInterstitial;

  /// Fallback rewarded ID when you don't use remote config providers.
  static String get rewarded => kReleaseMode ? defaultProdRewarded : testRewarded;
}