import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home&alanding/loading_screen.dart';
import 'theme/app_theme.dart';

const String _themeModeKey = 'klug_theme_mode';

// Global theme notifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

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
    _persistTheme(themeNotifier.value);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
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
      title: 'KLUG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeNotifier.value,
      home: const LoadingScreen(),
    );
  }
}
