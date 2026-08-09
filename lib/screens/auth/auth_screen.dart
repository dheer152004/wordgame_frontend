import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/auth_models.dart';
import '../../services/backend_api.dart';
import '../../services/session_store.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

enum _AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = _AuthMode.login});

  final _AuthMode initialMode;

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
    _mode = widget.initialMode;
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

  Future<void> _handleForgotPassword(String email) async {
    try {
      final message = await BackendApi.instance.forgotPassword(email);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } on BackendException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
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
    const pageBackground = Color(0xFFF8FAFF);
    const cardBackground = Color(0xFFFFFFFF);
    const primaryText = Color(0xFF0F172A);
    const secondaryText = Color(0xFF475569);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const primaryBlue = Color(0xFF2563EB);

    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: primaryText,
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? 'Welcome Back!' : 'Create Account',
                  style: const TextStyle(
                    color: primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Log in to continue your learning journey.'
                      : 'Create a new account to keep your progress in sync.',
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isLogin) ...[
                        _buildLoginForm(),
                      ] else ...[
                        _buildRegisterForm(),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isLogin ? 'Log In' : 'Create Account',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLogin) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: borderColor)),
                      const SizedBox(width: 12),
                      Text(
                        'or continue with',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 1, color: borderColor)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/logo/google_logo.png',
                            width: 18,
                            height: 18,
                          ),
                          label: const Text(
                            'Google',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryText,
                            backgroundColor: cardBackground,
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/logo/apple_logo.png',
                            width: 18,
                            height: 18,
                          ),
                          label: const Text(
                            'Apple',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryText,
                            backgroundColor: cardBackground,
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(
                                  initialMode: _AuthMode.register,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(
                                  initialMode: _AuthMode.login,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
      onForgotPassword: _handleForgotPassword,
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
