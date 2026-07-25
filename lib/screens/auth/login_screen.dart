import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final Widget? errorBanner;

  const LoginScreen({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    this.errorMessage,
    this.errorBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey('login-form'),
        children: [
          _InputField(
            controller: usernameController,
            label: 'Username or email',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Username must be at least 3 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            errorBanner ?? const SizedBox.shrink(),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      textInputAction: widget.textInputAction,
      obscureText: _obscurePassword,
      validator: widget.validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(widget.icon, color: Colors.white70),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withAlpha(31)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.challengeCard.withAlpha(242)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFFA6A6)),
      ),
    );
  }
}
