import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/home&alanding/loading_screen.dart';
import 'services/auth_session_manager.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

const String _themeModeKey = 'nroq_theme_mode';

// Global theme notifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

ThemeMode _themeFromStorage(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

bool get _supportsCrashlytics =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  if (_supportsCrashlytics) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString(_themeModeKey);
  themeNotifier.value = _themeFromStorage(savedTheme);

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  runApp(const WordApp());
}

class WordApp extends StatefulWidget {
  const WordApp({super.key});

  @override
  State<WordApp> createState() => _WordAppState();
}

class _WordAppState extends State<WordApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChanged);
    AuthSessionManager.sessionExpired.addListener(_onSessionExpired);
    _persistTheme(themeNotifier.value);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    AuthSessionManager.sessionExpired.removeListener(_onSessionExpired);
    super.dispose();
  }

  void _onSessionExpired() {
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  void _onThemeChanged() {
    _persistTheme(themeNotifier.value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'NROQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeNotifier.value,
      home: const LoadingScreen(),
    );
  }
}
