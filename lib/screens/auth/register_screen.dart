import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController displayNameController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final Widget? errorBanner;

  const RegisterScreen({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.displayNameController,
    required this.passwordController,
    this.errorMessage,
    this.errorBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey('register-form'),
        children: [
          _InputField(
            controller: usernameController,
            label: 'Username',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Username must be at least 3 characters.';
              }
              if (value.trim().length > 20) {
                return 'Username must be 20 characters or fewer.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty ||
                  !email.contains('@') ||
                  !email.contains('.')) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: displayNameController,
            label: 'Display name',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().length > 40) {
                return 'Display name must be 40 characters or fewer.';
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Color.fromARGB(179, 21, 20, 20), fontSize: 12),
                children: [
                  const TextSpan(text: 'By signing in you accept our '),
                  TextSpan(
                    text: 'Terms of use',
                    style: const TextStyle(
                      color: AppColors.challengeCard,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                          Uri.parse('https://github.com'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy and policy',
                    style: const TextStyle(
                      color: AppColors.challengeCard,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                          Uri.parse('https://github.com'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                ],
              ),
            ),
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
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
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
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscurePassword,
      validator: widget.validator,
      style: const TextStyle(color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(widget.icon, color: const Color(0xFF94A3B8)),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: const Color(0xFF2563EB)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFFA6A6)),
      ),
    );
  }
}
