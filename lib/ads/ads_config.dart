class AdsConfig {
  const AdsConfig({
    required this.enabled,
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
  });

  final bool enabled;
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;

  factory AdsConfig.fromFirestoreMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};

    return AdsConfig(
      enabled: (map['enabled'] as bool?) ?? true,
      bannerAdUnitId: (map['banner_ad_unit_id'] as String?)?.trim(),
      interstitialAdUnitId: (map['interstitial_ad_unit_id'] as String?)?.trim(),
    );
  }
}

