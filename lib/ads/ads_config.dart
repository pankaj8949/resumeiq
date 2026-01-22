class AdsConfig {
  const AdsConfig({
    required this.enabled,
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
  });

  final bool enabled;
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;

  factory AdsConfig.fromFirestoreMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};

    return AdsConfig(
      enabled: (map['enabled'] as bool?) ?? true,
      bannerAdUnitId: (map['banner_ad_unit_id'] as String?)?.trim(),
      interstitialAdUnitId: (map['interstitial_ad_unit_id'] as String?)?.trim(),
      rewardedAdUnitId: (map['rewarded_ad_unit_id'] as String?)?.trim(),
    );
  }
}