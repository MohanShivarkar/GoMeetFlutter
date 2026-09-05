import 'package:dating/core/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'
    if (dart.library.html) 'package:dating/stubs/google_mobile_ads_stub.dart';

import '../presentation/screens/BottomNavBar/home_screen.dart';
import '../presentation/screens/splash_bording/splash_screen.dart';

InterstitialAd? _interstitialAd;
int _numInterstitialLoadAttempts = 0;
const int maxFailedLoadAttempts = 3;

AdWithView? _bannerAd;
bool _isLoaded = false;

const AdRequest request = AdRequest(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  nonPersonalizedAds: true,
);

AdWithView bannerADs(){
  return _bannerAd!;
}

InterstitialAd interstitialAda(){
  return _interstitialAd!;
}

void createInterstitialAd() {
  InterstitialAd.load(
    adUnitId: defaultTargetPlatform == TargetPlatform.android
        ? android_in_id
        : ios_in_id,
    request: request,
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print('$ad loadedMMM');
        _interstitialAd = ad;
        _numInterstitialLoadAttempts = 0;
        _interstitialAd!.setImmersiveMode(true);
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('InterstitialAd failed to load: $error.');
        _numInterstitialLoadAttempts += 1;
        _interstitialAd = null;
        if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
          createInterstitialAd();
        } else {}
      },
    ),
  );
}

void showInterstitialAd() {
  if (_interstitialAd == null) {
    print('Warning: attempt to show interstitial before loaded.');
    return;
  }
  _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) {
      print('ad onAdShowedFullScreenContent.');

    },
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('$ad onAdDismissedFullScreenContent.');
      ad.dispose();
      createInterstitialAd();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();
      createInterstitialAd();
    },
  );
  _interstitialAd!.show();
  _interstitialAd = null;
}


void loadAd() {
  _bannerAd = BannerAd(
    adUnitId: defaultTargetPlatform == TargetPlatform.android
        ? android_bannerid
        : ios_bannerid,
    request: const AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        debugPrint('$ad loaded.');
        _isLoaded = true;

      },
      onAdFailedToLoad: (ad, err) {
        debugPrint('BannerAd failed to load: $err');
        ad.dispose();
      },
    ),
  )..load();
}


