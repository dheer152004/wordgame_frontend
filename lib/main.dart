import 'package:flutter/material.dart';

import 'models/auth_models.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/session_store.dart';

void main() {
  runApp(const WordApp());
}

class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC5B8F8),
          background: const Color(0xFFF5F0EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<AuthUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = SessionStore.restoreUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return HomeScreen(user: snapshot.data);
        }

        return const AuthScreen();
      },
    );
  }
}
