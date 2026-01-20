import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../ads/admob_ids.dart';
import '../ads/ads_config.dart';

/// Firestore location:
/// - collection: `app_config`
/// - document: `ads`
///
/// Fields (all optional):
/// - enabled: bool
/// - banner_ad_unit_id: string
/// - interstitial_ad_unit_id: string
final adsConfigProvider = StreamProvider<AdsConfig>((ref) {
  final doc = FirebaseFirestore.instance.collection('app_config').doc('ads');
  return doc
      .snapshots()
      .map((snap) => AdsConfig.fromFirestoreMap(snap.data()))
      .handleError((e, st) {
    debugPrint('AdMob config Firestore error: $e');
  });
});

final adsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(adsConfigProvider).maybeWhen(
        data: (cfg) => cfg.enabled,
        orElse: () => true,
      );
});

/// Banner unit id:
/// - Firestore value if present (debug + release)
/// - Otherwise falls back to Google TEST ID (so you don't accidentally show prod ads)
final bannerAdUnitIdProvider = Provider<String>((ref) {
  final cfg = ref.watch(adsConfigProvider).maybeWhen(
        data: (c) => c,
        orElse: () => null,
      );
  return (cfg?.bannerAdUnitId?.isNotEmpty == true)
      ? cfg!.bannerAdUnitId!
      : AdMobIds.testBanner;
});

/// Interstitial unit id:
/// - Firestore value if present (debug + release)
/// - Otherwise falls back to Google TEST ID (so you don't accidentally show prod ads)
final interstitialAdUnitIdProvider = Provider<String>((ref) {
  final cfg = ref.watch(adsConfigProvider).maybeWhen(
        data: (c) => c,
        orElse: () => null,
      );
  return (cfg?.interstitialAdUnitId?.isNotEmpty == true)
      ? cfg!.interstitialAdUnitId!
      : AdMobIds.testInterstitial;
});