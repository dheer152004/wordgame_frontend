import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../auth/auth_screen.dart';
import 'onboarding_screen.dart';
import '../home/home_screen.dart';
import '../../services/session_store.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      // Try to restore saved user session
      final savedUser = await SessionStore.restoreUser();

      if (savedUser != null) {
        // User has a saved session, go directly to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: savedUser)),
        );
      } else {
        // No saved session, show onboarding first if needed.
        final seenOnboarding = await SessionStore.hasSeenOnboarding();
        if (!mounted) return;
        if (seenOnboarding) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        } else {
          final completed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          if (!mounted) return;
          if (completed == true) {
            await SessionStore.markOnboardingSeen();
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error during bootstrap: $e');
      // Fallback to auth on error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _logoScale,
          child: SvgPicture.asset(
            'assets/icons/nroqfull.svg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
