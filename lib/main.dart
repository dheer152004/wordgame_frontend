import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const WordApp());
}

class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display', // uses system font fallback on Android
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC5B8F8),
          background: const Color(0xFFF5F0EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const AuthScreen(),
    );
  }
}
