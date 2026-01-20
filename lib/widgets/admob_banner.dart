import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/ads_provider.dart';

class AdMobBanner extends ConsumerStatefulWidget {
  const AdMobBanner({
    super.key,
    this.size = AdSize.banner,
    this.backgroundColor,
  });

  final AdSize size;
  final Color? backgroundColor;

  @override
  ConsumerState<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends ConsumerState<AdMobBanner> {
  BannerAd? _banner;
  bool _isLoaded = false;
  String? _loadedUnitId;

  @override
  void initState() {
    super.initState();
  }

  void _disposeBanner() {
    _banner?.dispose();
    _banner = null;
    _isLoaded = false;
    _loadedUnitId = null;
  }

  void _load(String adUnitId) {
    final banner = BannerAd(
      adUnitId: adUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _banner = ad as BannerAd;
            _isLoaded = true;
            _loadedUnitId = adUnitId;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _banner = null;
            _isLoaded = false;
            _loadedUnitId = null;
          });
        },
      ),
    );

    banner.load();
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(adsEnabledProvider);
    if (!enabled) {
      if (_banner != null) _disposeBanner();
      return const SizedBox.shrink();
    }

    final adUnitId = ref.watch(bannerAdUnitIdProvider);
    if (_loadedUnitId != adUnitId) {
      // Firestore value changed (or first build): reload banner with latest ID.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _disposeBanner();
        _load(adUnitId);
      });
    }

    if (!_isLoaded || _banner == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      color: widget.backgroundColor,
      alignment: Alignment.center,
      child: AdWidget(ad: _banner!),
    );
  }
}

