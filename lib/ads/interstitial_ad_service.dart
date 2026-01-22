import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_ids.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static InterstitialAd? _ad;
  static bool _isLoading = false;
  static DateTime? _lastShownAt;

  static bool get isAvailable => _ad != null;

  static Future<void> load({String? adUnitId}) async {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: adUnitId ?? AdMobIds.interstitial,
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
  static bool showIfAvailable({
    VoidCallback? onDismissed,
    String? adUnitId,
    Duration minInterval = const Duration(seconds: 60),
  }) {
    final lastShownAt = _lastShownAt;
    if (lastShownAt != null &&
        DateTime.now().difference(lastShownAt) < minInterval) {
      load(adUnitId: adUnitId);
      return false;
    }

    final ad = _ad;
    if (ad == null) {
      load(adUnitId: adUnitId);
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _lastShownAt = DateTime.now();
        onDismissed?.call();
        // Preload the next one.
        // ignore: unawaited_futures
        load(adUnitId: adUnitId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        load(adUnitId: adUnitId);
      },
    );

    ad.show();
    _lastShownAt = DateTime.now();
    _ad = null;
    return true;
  }

  static Future<bool> showAfterLoad({
    VoidCallback? onDismissed,
    required String adUnitId,
    Duration timeout = const Duration(seconds: 3),
    Duration pollInterval = const Duration(milliseconds: 120),
    Duration minInterval = const Duration(seconds: 60),
  }) async {
    load(adUnitId: adUnitId);

    final end = DateTime.now().add(timeout);
    while (_ad == null && DateTime.now().isBefore(end)) {
      await Future.delayed(pollInterval);
    }

    return showIfAvailable(
      adUnitId: adUnitId,
      minInterval: minInterval,
      onDismissed: onDismissed,
    );
  }

  static void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}