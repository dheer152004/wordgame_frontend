import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Backend API
  static String get backendApiBaseUrl {
    return dotenv.env['BACKEND_API_BASE_URL'] ??
        'https://wordgame-backend-2sza.onrender.com';
  }

  // AdMob App IDs
  static String get admobAppIdAndroid {
    return dotenv.env['ADMOB_APP_ID_ANDROID'] ?? '';
  }

  static String get admobAppIdIos {
    return dotenv.env['ADMOB_APP_ID_IOS'] ?? '';
  }

  // AdMob Ad Unit IDs
  static String get admobNativeAdUnitId {
    return dotenv.env['ADMOB_NATIVE_AD_UNIT_ID'] ??
        'ca-app-pub-3940256099942544/2247696110'; //change it
  }

  static String get admobInterstitialAdUnitId {
    return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID'] ??
        'ca-app-pub-3940256099942544/1033173712';
  }

  static String get admobRewardedAdUnitId {
    return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID'] ??
        'ca-app-pub-3940256099942544/5224354917';
  }

  // API Keys
  static String get apiKey {
    return dotenv.env['API_KEY'] ?? '';
  }

  static String get secretKey {
    return dotenv.env['SECRET_KEY'] ?? '';
  }

  // Authentication
  static String get authToken {
    return dotenv.env['AUTH_TOKEN'] ?? '';
  }
}
