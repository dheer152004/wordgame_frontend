import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final Widget? errorBanner;
  final Future<void> Function(String email)? onForgotPassword;

  const LoginScreen({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    this.errorMessage,
    this.errorBanner,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey('login-form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputField(
            controller: usernameController,
            label: 'Email or Phone',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or phone number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final emailController = TextEditingController();
                final email = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFFFFFFFF),
                      surfaceTintColor: Colors.white,
                      title: const Text(
                        'Reset password',
                        style: TextStyle(color: Color(0xFF0F172A)),
                      ),
                      content: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFF),
                          labelText: 'Email address',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          hintText: 'you@example.com',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(
                            dialogContext,
                          ).pop(emailController.text.trim()),
                          child: const Text('Send link'),
                        ),
                      ],
                    );
                  },
                );

                if (email != null &&
                    email.isNotEmpty &&
                    onForgotPassword != null) {
                  await onForgotPassword!(email);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Forgot Password?'),
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
