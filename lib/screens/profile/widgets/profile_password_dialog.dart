import 'package:flutter/material.dart';

import '../../../../services/backend_api.dart';
import '../../../../theme/app_theme.dart';

class ProfilePasswordDialog extends StatefulWidget {
  const ProfilePasswordDialog({super.key});

  @override
  State<ProfilePasswordDialog> createState() => _ProfilePasswordDialogState();
}

class _ProfilePasswordDialogState extends State<ProfilePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final canSave =
        !_isSaving &&
        currentPassword.isNotEmpty &&
        newPassword.length >= 6 &&
        newPassword == confirmPassword;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Change password'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                enabled: !_isSaving,
                obscureText: _obscureCurrent,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Current password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                enabled: !_isSaving,
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() {
                      _obscureNew = !_obscureNew;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                enabled: !_isSaving,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Use at least 6 characters and make sure the confirmation matches.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canSave ? _changePassword : null,
          child: Text(_isSaving ? 'Saving...' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    setState(() => _isSaving = true);

    try {
      await BackendApi.instance.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to change password: $error')),
      );
    }
  }
}
