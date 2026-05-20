import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';

class CustomNativeAd extends StatefulWidget {
  const CustomNativeAd({super.key});

  @override
  State<CustomNativeAd> createState() => _CustomNativeAdState();
}

class _CustomNativeAdState extends State<CustomNativeAd> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    // Skip ad loading on web platform
    if (kIsWeb) {
      return;
    }
    _nativeAd = NativeAd(
      adUnitId: AppConfig.admobNativeAdUnitId,
      factoryId: 'swipeAd',
      request: const AdRequest(),
      nativeAdOptions: NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.landscape,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _adLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_adLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_nativeAd != null)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: AdWidget(ad: _nativeAd!),
            ),
        ],
      ),
    );
  }
}

class InterstitialAdManager {
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();

  factory InterstitialAdManager() {
    return _instance;
  }

  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _adLoaded = false;

  void loadInterstitialAd() {
    // Skip ad loading on web platform
    if (kIsWeb) {
      return;
    }
    InterstitialAd.load(
      adUnitId: AppConfig.admobInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _adLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _adLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_adLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _adLoaded = false;
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _interstitialAd = null;
          _adLoaded = false;
        },
      );
      _interstitialAd!.show();
    }
  }

  bool get isAdReady => _adLoaded && _interstitialAd != null;
}

class RewardedVideoAdManager {
  static final RewardedVideoAdManager _instance =
      RewardedVideoAdManager._internal();

  factory RewardedVideoAdManager() {
    return _instance;
  }

  RewardedVideoAdManager._internal();

  RewardedAd? _rewardedAd;
  bool _adLoaded = false;

  void loadRewardedAd() {
    // Skip ad loading on web platform
    if (kIsWeb) {
      return;
    }
    RewardedAd.load(
      adUnitId: AppConfig.admobRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _adLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _adLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(int amount, String type) onUserEarnedReward,
  }) {
    if (_adLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _adLoaded = false;
          loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _rewardedAd = null;
          _adLoaded = false;
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          onUserEarnedReward(rewardItem.amount.toInt(), rewardItem.type);
        },
      );
    }
  }

  bool get isAdReady => _adLoaded && _rewardedAd != null;
}
