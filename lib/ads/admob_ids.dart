import 'package:flutter/foundation.dart';

/// Central place for AdMob ad unit IDs.
///
/// During development, we use Google-provided TEST ad unit IDs to avoid
/// accidental policy violations / invalid traffic.
/// In release builds, we use your real AdMob IDs.
class AdMobIds {
  AdMobIds._();

  // Google TEST IDs (safe for development)
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  // Your production IDs
  static const String _prodBanner = 'ca-app-pub-7138268980308783/4668697619';
  static const String _prodInterstitial =
      'ca-app-pub-7138268980308783/1040443792';

  static String get banner => kReleaseMode ? _prodBanner : _testBanner;

  static String get interstitial =>
      kReleaseMode ? _prodInterstitial : _testInterstitial;
}

