import 'package:flutter/material.dart';

import '../../../../models/profile_models.dart';
import '../../../../services/backend_api.dart';
import '../../../../services/session_store.dart';
import '../../../../theme/app_theme.dart';
import 'profile_avatar_option.dart';
import 'profile_avatar_preview.dart';

class ProfileEditDialog extends StatefulWidget {
  final UserProfile currentProfile;
  final UserProfile? existingUser;
  final String avatarSeed;
  final List<String> avatarStyles;
  final String Function({required String style, required String seed})
  buildAvatarUrl;
  final String? Function(String value) diceBearStyleFromUrl;
  final Future<void> Function(UserProfile updatedProfile) onProfileUpdated;

  const ProfileEditDialog({
    super.key,
    required this.currentProfile,
    required this.existingUser,
    required this.avatarSeed,
    required this.avatarStyles,
    required this.buildAvatarUrl,
    required this.diceBearStyleFromUrl,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _bioController;
  late final List<({String style, String url})> _avatarOptions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.currentProfile.displayName,
    );
    _avatarUrlController = TextEditingController(
      text: widget.currentProfile.avatarUrl,
    );
    _bioController = TextEditingController(text: widget.currentProfile.bio);
    _avatarOptions = widget.avatarStyles
        .map(
          (style) => (
            style: style,
            url: widget.buildAvatarUrl(style: style, seed: widget.avatarSeed),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeColors.surface(context),
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatarPreview(avatarUrl: _avatarUrlController.text.trim()),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                enabled: !_isSaving,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _avatarUrlController,
                enabled: !_isSaving,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pick from DiceBear avatars',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in _avatarOptions)
                    ProfileAvatarOption(
                      url: option.url,
                      label: option.style,
                      selected:
                          _avatarUrlController.text.trim() == option.url ||
                          widget.diceBearStyleFromUrl(
                                _avatarUrlController.text.trim(),
                              ) ==
                              option.style,
                      enabled: !_isSaving,
                      onTap: () {
                        _avatarUrlController.text = option.url;
                        _avatarUrlController.selection =
                            TextSelection.collapsed(
                              offset: _avatarUrlController.text.length,
                            );
                        setState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Powered by api.dicebear.com. You can still paste any custom image URL above.',
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                enabled: !_isSaving,
                onChanged: (_) => setState(() {}),
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 12),
              Text(
                'Location is detected automatically from your IP address.',
                style: TextStyle(color: AppThemeColors.textSecondary(context)),
              ),
              const SizedBox(height: 8),
              Text(
                _avatarUrlController.text.trim().isEmpty
                    ? 'Paste a direct image URL to preview the avatar.'
                    : 'Preview updates as you edit the URL.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12,
                ),
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
          onPressed: _isSaving ? null : _saveProfile,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final location = await BackendApi.instance.fetchLocationFromIp();
      final updatedProfile = await BackendApi.instance.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
        bio: _bioController.text.trim(),
        location: location,
      );

      final avatarUrl = _avatarUrlController.text.trim();
      final profileWithAvatar = avatarUrl.isNotEmpty
          ? await BackendApi.instance.uploadUserAvatarFromUrl(avatarUrl)
          : updatedProfile.copyWith(avatarUrl: '');

      final mergedProfile = profileWithAvatar.copyWith(
        token: widget.existingUser?.token ?? '',
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        location: location,
      );

      await widget.onProfileUpdated(mergedProfile);
      await SessionStore.saveUser(mergedProfile);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update profile: $error')),
      );
    }
  }
}
