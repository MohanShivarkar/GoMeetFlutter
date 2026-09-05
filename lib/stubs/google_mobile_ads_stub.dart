// lib/stubs/google_mobile_ads_stub.dart
//
// Web stub for google_mobile_ads.
// Selected by conditional import when dart.library.html is available.
// Google Mobile Ads are not available on web; all operations are no-ops.

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/widgets.dart';

class AdRequest {
  final List<String>? keywords;
  final String? contentUrl;
  final bool? nonPersonalizedAds;
  const AdRequest({this.keywords, this.contentUrl, this.nonPersonalizedAds});
}

class LoadAdError {
  final int code;
  final String domain;
  final String message;
  const LoadAdError(this.code, this.domain, this.message);
  @override
  String toString() => 'LoadAdError($code, $domain, $message)';
}

class AdError {
  final int code;
  final String domain;
  final String message;
  const AdError(this.code, this.domain, this.message);
  @override
  String toString() => 'AdError($code, $domain, $message)';
}

abstract class AdWithView {
  void dispose() {}
}

class FullScreenContentCallback<T extends Ad> {
  final void Function(T ad)? onAdShowedFullScreenContent;
  final void Function(T ad)? onAdDismissedFullScreenContent;
  final void Function(T ad, AdError error)? onAdFailedToShowFullScreenContent;
  const FullScreenContentCallback({
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
  });
}

abstract class Ad {
  void dispose() {}
}

class InterstitialAd extends Ad {
  FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback;

  Future<void> show() async {}
  Future<void> setImmersiveMode(bool enable) async {}

  static Future<void> load({
    required String adUnitId,
    required AdRequest request,
    required InterstitialAdLoadCallback adLoadCallback,
  }) async {}
}

class InterstitialAdLoadCallback {
  final void Function(InterstitialAd ad) onAdLoaded;
  final void Function(LoadAdError error) onAdFailedToLoad;
  const InterstitialAdLoadCallback({
    required this.onAdLoaded,
    required this.onAdFailedToLoad,
  });
}

class AdSize {
  final int width;
  final int height;
  const AdSize(this.width, this.height);
  static const AdSize banner = AdSize(320, 50);
  static const AdSize largeBanner = AdSize(320, 100);
  static const AdSize mediumRectangle = AdSize(300, 250);
}

class BannerAdListener {
  final void Function(AdWithView ad)? onAdLoaded;
  final void Function(AdWithView ad, LoadAdError error)? onAdFailedToLoad;
  const BannerAdListener({this.onAdLoaded, this.onAdFailedToLoad});
}

class BannerAd extends AdWithView {
  final String adUnitId;
  final AdRequest request;
  final AdSize size;
  final BannerAdListener listener;

  BannerAd({
    required this.adUnitId,
    required this.request,
    required this.size,
    required this.listener,
  });

  Future<void> load() async {}
  @override
  void dispose() {}
}

class AdWidget extends StatelessWidget {
  final AdWithView ad;
  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
