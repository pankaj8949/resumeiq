import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Minimal rewarded ad loader/show helper.
///
/// Use-case here: show a rewarded ad on user actions (Save/Share).
/// We run [onAfter] after the ad is dismissed (or if it can't show).
class RewardedAdService {
  RewardedAdService._();

  static RewardedAd? _ad;
  static bool _isLoading = false;

  static bool get isAvailable => _ad != null;

  static Future<void> load({required String adUnitId}) async {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
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

  /// Ensures an ad is loaded, then tries to show it.
  /// Returns true if it actually showed an ad.
  static Future<bool> showOrLoadAndShow({
    required String adUnitId,
    VoidCallback? onAfter,
    void Function(RewardItem reward)? onUserEarnedReward,
    Duration loadTimeout = const Duration(seconds: 6),
  }) async {
    // If we don't have one ready, load and wait a bit.
    if (_ad == null) {
      await load(adUnitId: adUnitId);
      final start = DateTime.now();
      while (_ad == null &&
          _isLoading &&
          DateTime.now().difference(start) < loadTimeout) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }

    final ad = _ad;
    if (ad == null) {
      onAfter?.call();
      return false;
    }

    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        onAfter?.call();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        onAfter?.call();
        completer.complete(false);
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward?.call(reward);
      },
    );

    // The ad object cannot be reused after show().
    _ad = null;
    return completer.future;
  }

  static void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

