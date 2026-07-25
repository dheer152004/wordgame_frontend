import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home&alanding/loading_screen.dart';
import 'theme/app_theme.dart';

// Global theme notifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env file
  await dotenv.load();
  // Only initialize MobileAds on mobile platforms (not on web)
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
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
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
