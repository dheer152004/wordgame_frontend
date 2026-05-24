import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/profile_models.dart';
import '../services/backend_api.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import '../widgets/profile_saved_words_section.dart';

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
    // Check if we have cached data and it's not expired
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
    } catch (error) {
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
    final profile = _profile;
    final avatarUrl = _resolvedAvatarUrl(profile);
    final displayName = profile?.greetingName.isNotEmpty == true
        ? profile!.greetingName
        : (isSignedIn && user!.greetingName.isNotEmpty
              ? user!.greetingName
              : 'Guest');
    final subtitle = profile?.bio.isNotEmpty == true
        ? profile!.bio
        : (isSignedIn
              ? 'Your account details and learning stats'
              : 'You are browsing as a guest');

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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                              IconButton(
                                onPressed: isSignedIn ? _fetchProfile : null,
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: 'Refresh profile',
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
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
                          IconButton(
                            onPressed: () =>
                                _fetchQuizStats(forceRefresh: true),
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Refresh stats',
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildStatsDisplay(_quizStats),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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
        _buildAvatarPreview(_resolvedAvatarUrl(profile)),
        const SizedBox(height: 16),
        _InfoTile(label: 'Username', value: profile.username),
        _InfoTile(label: 'Email', value: profile.email),
        _InfoTile(
          label: 'Display name',
          value: profile.displayName.isNotEmpty
              ? profile.displayName
              : 'Not set',
        ),
        _InfoTile(label: 'Bio', value: _displayValue(profile.bio)),
        _InfoTile(label: 'Location', value: _displayValue(profile.location)),
        _InfoTile(label: 'User ID', value: profile.id.toString()),
        _InfoTile(label: 'Level', value: profile.level.toString()),
        _InfoTile(label: 'Total XP', value: profile.totalXp.toString()),
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
        if (profile.recentBadges.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text(
            'Recent badges',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in profile.recentBadges)
                _BadgeChip(label: badge),
            ],
          ),
        ],
      ],
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

class _BadgeChip extends StatelessWidget {
  final String label;

  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.challengeCard.withAlpha(42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
