import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/profile_models.dart';
import '../services/session_store.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import '../widgets/profile_saved_words_section.dart';
import '../widgets/screen_action_buttons.dart';
import 'saved_words_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _diceBearApiRoot = 'https://api.dicebear.com/9.x';
  static const List<String> _diceBearAvatarStyles = <String>[
    'adventurer',
    'avataaars',
    'big-ears',
    'bottts',
    'fun-emoji',
    'identicon',
    'lorelei',
    'micah',
    'pixel-art',
    'shapes',
  ];

  UserProfile? user;
  UserProfile? _profile;
  bool _loadingProfile = false;
  dynamic _quizStats;
  bool _loadingStats = false;
  dynamic _cachedQuizStats;
  DateTime? _cacheTime;
  static const Duration _cacheExpiration = Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _restoreSessionUser();
  }

  Future<void> _restoreSessionUser() async {
    user ??= await SessionStore.restoreUser();
    _fetchProfile();
    _fetchQuizStats();
  }

  Future<void> _fetchProfile() async {
    if (user == null) {
      return;
    }
    setState(() {
      _loadingProfile = true;
    });

    try {
      final profile = await BackendApi.instance.fetchUserProfile();
      if (mounted) {
        setState(() {
          _profile = _mergeAvatarPreference(profile);
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Future<void> _fetchQuizStats({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedQuizStats != null && _cacheTime != null) {
      final elapsed = DateTime.now().difference(_cacheTime!);
      if (elapsed < _cacheExpiration) {
        setState(() {
          _quizStats = _cachedQuizStats;
        });
        return;
      }
    }

    setState(() {
      _loadingStats = true;
    });

    try {
      final stats = await BackendApi.instance.fetchQuizStats();
      if (mounted) {
        setState(() {
          _quizStats = stats;
          _cachedQuizStats = stats;
          _cacheTime = DateTime.now();
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingStats = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await SessionStore.clear();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackIconButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 6),
                  const Text('Profile', style: AppTextStyles.sectionTitle),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Profile Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: isSignedIn ? _editProfile : null,
                              icon: const Icon(Icons.edit_rounded),
                              tooltip: 'Edit profile',
                              iconSize: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            if (_loadingProfile)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              AppRefreshIconButton(
                                onPressed: isSignedIn ? _fetchProfile : null,
                                tooltip: 'Refresh profile',
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_profile != null)
                      _buildProfileDetails(_profile!)
                    else if (isSignedIn)
                      const Text(
                        'Loading profile details...',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      const Text(
                        'Log in to load profile details.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const ProfileSavedWordsSection(),
              const SizedBox(height: 18),
              if (_loadingStats)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (_quizStats != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quiz Stats',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppRefreshIconButton(
                            onPressed: () =>
                                _fetchQuizStats(forceRefresh: true),
                            tooltip: 'Refresh stats',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildStatsDisplay(_quizStats),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Badges earned section
                if (_profile != null && _profile!.recentBadges.isNotEmpty) ...[
                  _buildBadgesSection(_profile!),
                  const SizedBox(height: 18),
                ],
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SegmentedButton<ThemeMode>(
                          segments: const <ButtonSegment<ThemeMode>>[
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: <ThemeMode>{themeNotifier.value},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            setState(() {
                              themeNotifier.value = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your account password without leaving the profile page.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: isSignedIn ? _changePassword : null,
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('Change password'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: Colors.white.withAlpha(24)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.challengeCard.withAlpha(31),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: Colors.white.withAlpha(16)),
                ),
                child: Text(
                  isSignedIn
                      ? 'Signed in sessions are restored automatically on launch.'
                      : 'Log in to see your profile details and unlock progress sync.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSignedIn ? () => _logout(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.challengeCard,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black.withAlpha(72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    isSignedIn ? 'Log out' : 'Log in to manage profile',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    if (user == null) {
      return;
    }

    UserProfile currentProfile = _profile ?? user!;
    if (_profile == null) {
      try {
        currentProfile = await BackendApi.instance.fetchUserProfile();
      } catch (error) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load profile: $error')),
        );
        return;
      }
    }

    final displayNameController = TextEditingController(
      text: currentProfile.displayName,
    );
    final avatarUrlController = TextEditingController(
      text: _resolvedAvatarUrl(currentProfile),
    );
    final bioController = TextEditingController(text: currentProfile.bio);
    final avatarSeed = _avatarSeed(currentProfile);
    final diceBearAvatars = _diceBearAvatarStyles
        .map(
          (style) => (
            style: style,
            url: _buildDiceBearAvatarUrl(style: style, seed: avatarSeed),
          ),
        )
        .toList();
    var isSaving = false;
    var _obscureCurrent = true;
    var _obscureNew = true;
    var _obscureConfirm = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Edit profile'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAvatarPreview(avatarUrlController.text.trim()),
                        const SizedBox(height: 16),
                        TextField(
                          controller: displayNameController,
                          enabled: !isSaving,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: avatarUrlController,
                          enabled: !isSaving,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Avatar URL',
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pick from DiceBear avatars',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final option in diceBearAvatars)
                              _buildAvatarOption(
                                url: option.url,
                                label: option.style,
                                selected:
                                    avatarUrlController.text.trim() ==
                                        option.url ||
                                    _diceBearStyleFromUrl(
                                          avatarUrlController.text.trim(),
                                        ) ==
                                        option.style,
                                enabled: !isSaving,
                                onTap: () {
                                  avatarUrlController.text = option.url;
                                  avatarUrlController.selection =
                                      TextSelection.collapsed(
                                        offset: avatarUrlController.text.length,
                                      );
                                  setDialogState(() {});
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Powered by api.dicebear.com. You can still paste any custom image URL above.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bioController,
                          enabled: !isSaving,
                          onChanged: (_) => setDialogState(() {}),
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(labelText: 'Bio'),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Location is detected automatically from your IP address.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          avatarUrlController.text.trim().isEmpty
                              ? 'Paste a direct image URL to preview the avatar.'
                              : 'Preview updates as you edit the URL.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              final location = await BackendApi.instance
                                  .fetchLocationFromIp();
                              final updatedProfile = await BackendApi.instance
                                  .updateUserProfile(
                                    displayName: displayNameController.text
                                        .trim(),
                                    avatarUrl: avatarUrlController.text.trim(),
                                    bio: bioController.text.trim(),
                                    location: location,
                                  );

                              final avatarUrl = avatarUrlController.text.trim();
                              final profileWithAvatar = avatarUrl.isNotEmpty
                                  ? await BackendApi.instance
                                        .uploadUserAvatarFromUrl(avatarUrl)
                                  : updatedProfile.copyWith(avatarUrl: '');

                              final mergedProfile = profileWithAvatar.copyWith(
                                token: user!.token,
                                displayName: displayNameController.text.trim(),
                                bio: bioController.text.trim(),
                                location: location,
                              );

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _profile = mergedProfile;
                                user = mergedProfile;
                              });
                              await SessionStore.saveUser(mergedProfile);

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated.'),
                                ),
                              );
                            } catch (error) {
                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                isSaving = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Unable to update profile: $error',
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(isSaving ? 'Saving...' : 'Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      displayNameController.dispose();
      avatarUrlController.dispose();
      bioController.dispose();
    }
  }

  Future<void> _changePassword() async {
    if (user == null) {
      return;
    }

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isSaving = false;
    var _obscureCurrent = true;
    var _obscureNew = true;
    var _obscureConfirm = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;
              final canSave =
                  !isSaving &&
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
                          controller: currentPasswordController,
                          enabled: !isSaving,
                          obscureText: _obscureCurrent,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Current password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setDialogState(() {
                                _obscureCurrent = !_obscureCurrent;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: newPasswordController,
                          enabled: !isSaving,
                          obscureText: _obscureNew,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: 'New password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setDialogState(() {
                                _obscureNew = !_obscureNew;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPasswordController,
                          enabled: !isSaving,
                          obscureText: _obscureConfirm,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Confirm new password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setDialogState(() {
                                _obscureConfirm = !_obscureConfirm;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Use at least 6 characters and make sure the confirmation matches.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: canSave
                        ? () async {
                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              await BackendApi.instance.changePassword(
                                currentPassword: currentPasswordController.text
                                    .trim(),
                                newPassword: newPasswordController.text.trim(),
                                confirmPassword: confirmPasswordController.text
                                    .trim(),
                              );

                              if (!mounted) {
                                return;
                              }

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password updated.'),
                                ),
                              );
                            } catch (error) {
                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                isSaving = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Unable to change password: $error',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(isSaving ? 'Saving...' : 'Update'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  Widget _buildStatsDisplay(dynamic stats) {
    if (stats == null) {
      return const Text(
        'No stats available',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    if (stats is Map<String, dynamic>) {
      final entries = stats.entries
          .where((entry) => entry.value != null)
          .toList();

      if (entries.isEmpty) {
        return const Text(
          'No stats available',
          style: TextStyle(color: AppColors.textSecondary),
        );
      }

      return Column(
        children: [
          for (final entry in entries) ...[
            _StatRow(label: entry.key, value: entry.value.toString()),
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    return Text(
      stats.toString(),
      style: const TextStyle(color: AppColors.textSecondary),
    );
  }

  Widget _buildProfileDetails(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarPreview(_resolvedAvatarUrl(profile)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.displayName.isNotEmpty
                        ? profile.displayName
                        : (profile.username.isNotEmpty
                              ? profile.username
                              : 'Guest'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.bio.isNotEmpty ? profile.bio : 'No bio',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: user == null ? null : _editProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.challengeCard,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Compact metrics row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _metricCard(label: 'Level', value: profile.level.toString()),
            const SizedBox(width: 8),
            _metricCard(label: 'XP', value: profile.totalXp.toString()),
            const SizedBox(width: 8),
            _metricCard(
              label: 'Mastered',
              value: profile.wordsMastered.toString(),
            ),
            const SizedBox(width: 8),
            _metricCard(
              label: 'Avg Quiz',
              value: profile.averageQuizScore.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Info tiles continue
        _InfoTile(label: 'Username', value: profile.username),
        _InfoTile(label: 'Email', value: profile.email),
        // _InfoTile(label: 'Display name',value: profile.displayName.isNotEmpty? profile.displayName: 'Not set',),
        _InfoTile(label: 'Bio', value: _displayValue(profile.bio)),
        _InfoTile(label: 'Location', value: _displayValue(profile.location)),
        // _InfoTile(label: 'User ID', value: profile.id.toString()),
        // _InfoTile(label: 'Level', value: profile.level.toString()),
        // _InfoTile(label: 'Total XP', value: profile.totalXp.toString()),
        _InfoTile(
          label: 'XP to next level',
          value: profile.xpToNextLevel.toString(),
        ),
        _InfoTile(
          label: 'Level progress',
          value: '${profile.levelProgress.toStringAsFixed(0)}%',
        ),
        _InfoTile(
          label: 'Current streak',
          value: '${profile.currentStreak} Days',
        ),
        _InfoTile(
          label: 'Longest streak',
          value: '${profile.longestStreak} Days',
        ),
        _InfoTile(
          label: 'Total words saved',
          value: profile.totalWordsSaved.toString(),
        ),
        _InfoTile(
          label: 'Quizzes completed',
          value: profile.totalQuizzesCompleted.toString(),
        ),
        _InfoTile(
          label: 'Average quiz score',
          value: profile.averageQuizScore.toStringAsFixed(1),
        ),
        _InfoTile(
          label: 'Words mastered',
          value: profile.wordsMastered.toString(),
        ),
        _InfoTile(
          label: 'Last active',
          value: _formatDateTime(profile.lastActive),
        ),
        _InfoTile(
          label: 'Created at',
          value: _formatDateTime(profile.createdAt),
        ),
        _InfoTile(
          label: 'Last quiz date',
          value: _displayValue(profile.lastQuizDate),
        ),
        // Badges moved to a dedicated section below (Badges Earned)
        const SizedBox(height: 18),
        // Quick actions / tiles
        const Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _quickActionTile(
          icon: Icons.favorite_border,
          label: 'Saved words',
          subtitle: '${profile.totalWordsSaved} saved',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => SavedWordsScreen())),
        ),
        // _quickActionTile(
        //   icon: Icons.download_rounded,
        //   label: 'Downloads',
        //   subtitle: 'Manage offline packs',
        //   onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Downloads not implemented yet.')),
        //   ),
        // ),
        // _quickActionTile(
        //   icon: Icons.language_rounded,
        //   label: 'Language',
        //   subtitle: profile.location.isNotEmpty
        //       ? profile.location
        //       : 'Auto-detect',
        //   onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Language selector not implemented.')),
        //   ),
        // ),
        _quickActionTile(
          icon: Icons.location_on_outlined,
          label: 'Location',
          subtitle: profile.location.isNotEmpty ? profile.location : 'Unknown',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location settings not implemented.')),
          ),
        ),
        _quickActionTile(
          icon: Icons.clear_all_rounded,
          label: 'Clear cache',
          subtitle: 'Free up storage',
          onTap: () async {
            await SessionStore.clearCache();
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cache cleared.')));
          },
        ),
        _quickActionTile(
          icon: Icons.history_toggle_off_rounded,
          label: 'Clear history',
          subtitle: 'Remove local activity',
          onTap: () async {
            await SessionStore.clearHistory();
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('History cleared.')));
          },
        ),
      ],
    );
  }

  // Small helper widgets
  Widget _metricCard({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(UserProfile profile) {
    final earnedBadges = profile.recentBadges
        .where((badge) => badge.trim().isNotEmpty)
        .toList(growable: false);
    final badgeCards = _badgeDefinitions();
    final badgeLookup = <String, _BadgeDefinition>{
      for (final badge in badgeCards) badge.label.toLowerCase(): badge,
      for (final badge in badgeCards) badge.alias.toLowerCase(): badge,
    };
    final earnedLookup = earnedBadges
        .map((badge) => badge.toLowerCase())
        .toSet();
    final displayCards = <_BadgeGalleryEntry>[];
    final targetCount = earnedBadges.length > 7 ? earnedBadges.length : 7;

    for (final earnedBadge in earnedBadges) {
      final normalized = earnedBadge.toLowerCase();
      final definition = badgeLookup[normalized];
      displayCards.add(
        _BadgeGalleryEntry(
          label: earnedBadge,
          icon: definition?.icon ?? Icons.emoji_events_rounded,
          accentColor: definition?.accentColor ?? AppColors.challengeCard,
          backgroundColor:
              definition?.backgroundColor ??
              AppColors.challengeCard.withAlpha(56),
          earned: true,
        ),
      );
    }

    for (final badge in badgeCards) {
      if (displayCards.length >= targetCount) {
        break;
      }

      final isEarned =
          earnedLookup.contains(badge.label.toLowerCase()) ||
          earnedLookup.contains(badge.alias.toLowerCase());
      if (isEarned) {
        continue;
      }

      displayCards.add(
        _BadgeGalleryEntry(
          label: badge.label,
          icon: badge.icon,
          accentColor: badge.accentColor,
          backgroundColor: badge.backgroundColor,
          earned: false,
        ),
      );
    }

    while (displayCards.length < targetCount) {
      displayCards.add(
        _BadgeGalleryEntry(
          label: 'Future badge',
          icon: Icons.lock_rounded,
          accentColor: Colors.white,
          backgroundColor: AppColors.surface.withAlpha(140),
          earned: false,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badges earned',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Earned badges stay bright. Locked badges stay blurred until you unlock them.',
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final badge in displayCards) ...[
                  _BadgeGalleryCard(
                    label: badge.label,
                    icon: badge.icon,
                    accentColor: badge.accentColor,
                    backgroundColor: badge.backgroundColor,
                    earned: badge.earned,
                  ),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_BadgeDefinition> _badgeDefinitions() {
    return const [
      _BadgeDefinition(
        label: 'Avoid puddles',
        alias: 'avoid puddles',
        icon: Icons.directions_walk_rounded,
        accentColor: Color(0xFF8EE6C7),
        backgroundColor: Color(0xFF16372E),
      ),
      _BadgeDefinition(
        label: 'Shake the tree',
        alias: 'shake the tree',
        icon: Icons.nature_rounded,
        accentColor: Color(0xFFA7F07D),
        backgroundColor: Color(0xFF223B14),
      ),
      _BadgeDefinition(
        label: 'Turn the mill',
        alias: 'turn the mill',
        icon: Icons.agriculture_rounded,
        accentColor: Color(0xFFF0D47A),
        backgroundColor: Color(0xFF42351B),
      ),
      _BadgeDefinition(
        label: 'Breathe slowly',
        alias: 'breathe slowly',
        icon: Icons.spa_rounded,
        accentColor: Color(0xFFF3A6B8),
        backgroundColor: Color(0xFF3B2030),
      ),
      _BadgeDefinition(
        label: 'Jump high',
        alias: 'jump high',
        icon: Icons.self_improvement_rounded,
        accentColor: Color(0xFF9FD4FF),
        backgroundColor: Color(0xFF18324A),
      ),
      _BadgeDefinition(
        label: 'Count stars',
        alias: 'count stars',
        icon: Icons.star_rounded,
        accentColor: Color(0xFFFFD36A),
        backgroundColor: Color(0xFF45361A),
      ),
      _BadgeDefinition(
        label: 'Sleep well',
        alias: 'sleep well',
        icon: Icons.nightlight_round,
        accentColor: Color(0xFFC3B6FF),
        backgroundColor: Color(0xFF2D2446),
      ),
    ];
  }

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.challengeCard.withAlpha(28),
          child: Icon(icon, color: AppColors.challengeCard),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  String _displayValue(String value) {
    return value.trim().isNotEmpty ? value : 'Not set';
  }

  UserProfile _mergeAvatarPreference(UserProfile fetchedProfile) {
    final normalizedFetchedAvatar = _normalizeLegacyAvatarUrl(
      fetchedProfile.avatarUrl,
      fetchedProfile,
    );

    if (normalizedFetchedAvatar != fetchedProfile.avatarUrl) {
      return fetchedProfile.copyWith(avatarUrl: normalizedFetchedAvatar);
    }

    return fetchedProfile;
  }

  String _resolvedAvatarUrl(UserProfile? profile) {
    final profileAvatar = _normalizeLegacyAvatarUrl(
      profile?.avatarUrl.trim() ?? '',
      profile ?? user,
    );
    if (profileAvatar.isNotEmpty) {
      // If backend returns a relative path, prefix with base URL.
      final trimmed = profileAvatar;
      if (trimmed.startsWith('/')) {
        return '${BackendApi.instance.baseUrl}$trimmed';
      }
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        return '${BackendApi.instance.baseUrl}/$trimmed';
      }
      return profileAvatar;
    }

    return '';
  }

  bool _isLegacyUiAvatarUrl(String value) {
    return value.contains('ui-avatars.com');
  }

  String _normalizeLegacyAvatarUrl(String value, UserProfile? sourceProfile) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (_isLegacyUiAvatarUrl(trimmed)) {
      return _buildDiceBearAvatarUrl(
        style: 'adventurer',
        seed: _avatarSeed(sourceProfile ?? user),
      );
    }

    return trimmed;
  }

  Widget _buildAvatarPreview(String avatarUrl) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.challengeCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.challengeCard.withAlpha(72),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withAlpha(18)),
        ),
        child: ClipOval(
          child: avatarUrl.isNotEmpty
              ? FutureBuilder<Uint8List>(
                  future: BackendApi.instance.fetchAvatarBytes(avatarUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        key: ValueKey(avatarUrl),
                        fit: BoxFit.cover,
                      );
                    }

                    // Fallback to Image.network without auth headers; if that fails show icon
                    return Image.network(
                      avatarUrl,
                      key: ValueKey('fallback-$avatarUrl'),
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                )
              : const Icon(Icons.person, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required String url,
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.challengeCard
                  : Colors.white.withAlpha(20),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.network(
                  url,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 42,
                    height: 42,
                    color: AppColors.challengeCard,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _avatarSeed(UserProfile? profile) {
    if (profile == null) {
      return 'guest';
    }

    final displayName = profile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile.username.trim();
    if (username.isNotEmpty) {
      return username;
    }

    return 'user-${profile.id}';
  }

  String _buildDiceBearAvatarUrl({
    required String style,
    required String seed,
  }) {
    final uri = Uri.parse(
      '$_diceBearApiRoot/$style/png',
    ).replace(queryParameters: <String, String>{'seed': seed, 'size': '128'});
    return uri.toString();
  }

  String? _diceBearStyleFromUrl(String value) {
    if (value.trim().isEmpty || !value.contains('api.dicebear.com')) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.pathSegments.length < 3) {
      return null;
    }

    return uri.pathSegments[1];
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not set';
    }

    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeDefinition {
  final String label;
  final String alias;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  const _BadgeDefinition({
    required this.label,
    required this.alias,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });
}

class _BadgeGalleryEntry {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool earned;

  const _BadgeGalleryEntry({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.earned,
  });
}

class _BadgeGalleryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool earned;

  const _BadgeGalleryCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBody = Container(
      width: 76,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: earned ? backgroundColor : AppColors.surface.withAlpha(140),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: earned
              ? accentColor.withAlpha(140)
              : Colors.white.withAlpha(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: earned
                  ? LinearGradient(
                      colors: [
                        accentColor.withAlpha(255),
                        accentColor.withAlpha(170),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: earned ? null : Colors.white.withAlpha(10),
            ),
            child: Icon(
              icon,
              color: earned ? Colors.white : Colors.white.withAlpha(120),
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: earned ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    final content = AnimatedOpacity(
      opacity: earned ? 1 : 0.42,
      duration: const Duration(milliseconds: 180),
      child: earned
          ? badgeBody
          : ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 1.9, sigmaY: 1.9),
              child: Stack(
                children: [
                  badgeBody,
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.black.withAlpha(10),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
    );

    return Padding(padding: const EdgeInsets.only(right: 0), child: content);
  }
}
