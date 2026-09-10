import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileAccountSection extends StatelessWidget {
  final bool isSignedIn;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteAccount;

  const ProfileAccountSection({
    super.key,
    required this.isSignedIn,
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update your password or permanently delete your account.',
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isSignedIn ? onChangePassword : null,
              icon: const Icon(Icons.lock_reset_rounded),
              label: const Text('Change password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeColors.textPrimary(context),
                side: BorderSide(color: AppThemeColors.divider(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isSignedIn ? onDeleteAccount : null,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withAlpha(120),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDeleteAccountDialog extends StatefulWidget {
  final Future<void> Function(String reason) onDelete;

  const ProfileDeleteAccountDialog({super.key, required this.onDelete});

  @override
  State<ProfileDeleteAccountDialog> createState() =>
      _ProfileDeleteAccountDialogState();
}

class _ProfileDeleteAccountDialogState
    extends State<ProfileDeleteAccountDialog> {
  static const _reasons = [
    'I no longer use this application',
    'I am concerned about my privacy',
    'The app does not meet my needs',
    'I am switching to another application',
    'I am having technical problems',
    'Other',
  ];

  final _otherReasonController = TextEditingController();
  String? _selectedReason;
  bool _isDeleting = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  String? get _reason {
    if (_selectedReason == 'Other') {
      final otherReason = _otherReasonController.text.trim();
      return otherReason.isEmpty ? null : otherReason;
    }
    return _selectedReason;
  }

  @override
  Widget build(BuildContext context) {
    final reason = _reason;

    return AlertDialog(
      backgroundColor: AppThemeColors.surface(context),
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently removes your account and cannot be undone. Why are you leaving?',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: _reasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: _isDeleting
                  ? null
                  : (value) => setState(() => _selectedReason = value),
            ),
            if (_selectedReason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otherReasonController,
                enabled: !_isDeleting,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Tell us why',
                  hintText: 'Enter your reason',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: reason == null || _isDeleting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(_isDeleting ? 'Deleting...' : 'Delete account'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete(reason);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete account: $error')),
      );
    }
  }
}
