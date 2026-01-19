import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_ids.dart';

/// Minimal interstitial ad loader/show helper.
///
/// Call [load] early (e.g. after login / when entering a flow),
/// then call [showIfAvailable] at a natural break (e.g. after finishing an action).
class InterstitialAdService {
  InterstitialAdService._();

  static InterstitialAd? _ad;
  static bool _isLoading = false;

  static bool get isAvailable => _ad != null;

  static Future<void> load() async {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AdMobIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Returns true if an ad was shown.
  static bool showIfAvailable({VoidCallback? onDismissed}) {
    final ad = _ad;
    if (ad == null) {
      // Best-effort: start loading for next time.
      // ignore: unawaited_futures
      load();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        onDismissed?.call();
        // Preload the next one.
        // ignore: unawaited_futures
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        // Try again next time.
        // ignore: unawaited_futures
        load();
      },
    );

    ad.show();
    // The ad object cannot be reused after show().
    _ad = null;
    return true;
  }

  static void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

