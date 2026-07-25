import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/auth_models.dart';
import '../../services/backend_api.dart';
import '../../services/session_store.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

enum _AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerDisplayNameController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _showError = true;
  Timer? _errorDismissTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final savedUsername = await SessionStore.getLoginUsername();
    if (savedUsername != null && mounted) {
      setState(() {
        _loginUsernameController.text = savedUsername;
      });
    }
  }

  @override
  void dispose() {
    _errorDismissTimer?.cancel();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerDisplayNameController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _setMode(_AuthMode mode) {
    if (_mode == mode) {
      return;
    }

    setState(() {
      _mode = mode;
      _errorMessage = null;
      _showError = true;
    });
  }

  Widget _buildErrorBanner() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _showError ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(179),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withAlpha(230), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isLogin = _mode == _AuthMode.login;
    final formState = isLogin
        ? _loginFormKey.currentState
        : _registerFormKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });
      if (isLogin) {
        final username = _loginUsernameController.text.trim();
        final user = await BackendApi.instance.login(
          LoginRequest(
            username: username,
            password: _loginPasswordController.text,
          ),
        );
        await SessionStore.saveUser(user);
        await SessionStore.saveLoginUsername(username);
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
        return;
      }

      final user = await BackendApi.instance.register(
        RegisterRequest(
          username: _registerUsernameController.text.trim(),
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text,
          displayName: _registerDisplayNameController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      if (user != null) {
        await SessionStore.saveUser(user);
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. You can log in now.')),
      );
      _setMode(_AuthMode.login);
    } on BackendException catch (error) {
      if (mounted) {
        // Display user-friendly error messages
        String displayMessage = error.message;
        if (error.message.contains('Bad credentials') ||
            error.message.contains('Authentication failed')) {
          displayMessage = 'Invalid credentials';
        }
        setState(() {
          _errorMessage = displayMessage;
          _showError = true;
        });

        // Auto-dismiss after 2 seconds
        _errorDismissTimer?.cancel();
        _errorDismissTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            // Trigger fade-out animation
            setState(() {
              _showError = false;
            });
            // Clear message after animation completes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _errorMessage = null;
                  _showError = true;
                });
              }
            });
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error: $error';
          _showError = true;
        });

        // Auto-dismiss after 2 seconds
        _errorDismissTimer?.cancel();
        _errorDismissTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            // Trigger fade-out animation
            setState(() {
              _showError = false;
            });
            // Clear message after animation completes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _errorMessage = null;
                  _showError = true;
                });
              }
            });
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF25112E), Color(0xFF101525), Color(0xFF05070D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minHeight: size.width * 0.72,
                      maxWidth: 500,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      color: Colors.white.withAlpha(20),
                      border: Border.all(color: Colors.white.withAlpha(46)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(89),
                          blurRadius: 36,
                          offset: const Offset(0, 18),
                        ),
                      ],
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              'assets/icons/KLUG(K)_transparent.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'KLUG',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Log in to sync your progress and explore the live word deck.'
                                : 'Register once and start learning live categories from the backend.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: _ModeToggle(mode: _mode, onChanged: _setMode),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: _AuthButton(
                      label: isLogin ? 'Log in' : 'Create account',
                      icon: isLogin
                          ? Icons.lock_open_rounded
                          : Icons.person_add_alt_1_rounded,
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.black87,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return LoginScreen(
      formKey: _loginFormKey,
      usernameController: _loginUsernameController,
      passwordController: _loginPasswordController,
      errorMessage: _errorMessage,
      errorBanner: _buildErrorBanner(),
    );
  }

  Widget _buildRegisterForm() {
    return RegisterScreen(
      formKey: _registerFormKey,
      usernameController: _registerUsernameController,
      emailController: _registerEmailController,
      displayNameController: _registerDisplayNameController,
      passwordController: _registerPasswordController,
      errorMessage: _errorMessage,
      errorBanner: _buildErrorBanner(),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color.fromARGB(255, 0, 0, 0).withAlpha(46),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Log in',
              selected: mode == _AuthMode.login,
              onTap: () => onChanged(_AuthMode.login),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Register',
              selected: mode == _AuthMode.register,
              onTap: () => onChanged(_AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Icon(icon, color: foregroundColor),
        label: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withAlpha(166),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withAlpha(26)),
          ),
        ),
      ),
    );
  }
}
