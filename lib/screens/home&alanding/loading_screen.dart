import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_screen.dart';
import 'onboarding_screen.dart';
import '../home/home_screen.dart';
import '../../services/auth_session_manager.dart';
import '../../services/app_version_service.dart';
import '../../services/session_store.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  Completer<void>? _storeReturnCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !(_storeReturnCompleter?.isCompleted ?? true)) {
      _storeReturnCompleter!.complete();
    }
  }

  Future<void> _bootstrap() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      final updateNotice = await AppVersionService.instance.checkForUpdate();
      if (!mounted) return;
      if (updateNotice != null) {
        final shouldContinue = await _showUpdateDialog(updateNotice);
        if (!mounted || !shouldContinue) return;
      }

      // Try to restore saved user session
      final savedUser = await AuthSessionManager.instance.restoreSession();
      if (!mounted) return;

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
            if (!mounted) return;
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

  Future<bool> _showUpdateDialog(AppUpdateNotice notice) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: !notice.forceUpdate,
          builder: (dialogContext) => PopScope(
            canPop: !notice.forceUpdate,
            child: AlertDialog(
              title: Text(notice.title),
              content: Text(notice.message),
              actions: [
                if (!notice.forceUpdate)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('LATER'),
                  ),
                FilledButton(
                  onPressed: () => _openUpdateStore(notice, dialogContext),
                  child: Text(notice.buttonText),
                ),
              ],
            ),
          ),
        ) ??
        !notice.forceUpdate;
  }

  Future<void> _openUpdateStore(
    AppUpdateNotice notice,
    BuildContext dialogContext,
  ) async {
    final storeUri = Uri.tryParse(notice.storeUrl);
    if (storeUri == null) {
      _showUpdateError('The app store link is invalid.');
      return;
    }

    final resumeCompleter = Completer<void>();
    if (notice.forceUpdate) {
      _storeReturnCompleter = resumeCompleter;
    }

    final opened = await launchUrl(
      storeUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      if (identical(_storeReturnCompleter, resumeCompleter)) {
        _storeReturnCompleter = null;
      }
      _showUpdateError('Could not open the app store.');
      return;
    }

    if (!notice.forceUpdate) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop(true);
      }
      return;
    }

    await resumeCompleter.future;
    if (identical(_storeReturnCompleter, resumeCompleter)) {
      _storeReturnCompleter = null;
    }
    if (!mounted || !dialogContext.mounted) return;

    try {
      final installed = await AppVersionService.instance
          .isInstalledVersionAtLeast(notice.latestVersion);
      if (!mounted || !dialogContext.mounted) return;
      if (installed) {
        Navigator.of(dialogContext).pop(true);
      } else {
        _showUpdateError(
          'Update not detected. Install it from the store to continue.',
        );
      }
    } catch (error) {
      debugPrint('Unable to verify installed app version: $error');
      _showUpdateError(
        'Could not verify the update. Try again after installing it.',
      );
    }
  }

  void _showUpdateError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
