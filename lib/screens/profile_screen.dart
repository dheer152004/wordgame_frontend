import 'package:flutter/material.dart';

import '../main.dart';
import '../models/profile_models.dart';
import '../services/backend_api.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
          _profile = profile;
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
    final avatarUrl = profile?.avatarUrl.isNotEmpty == true
        ? profile!.avatarUrl
        : (isSignedIn ? user!.avatarUrl : '');

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
      text: currentProfile.avatarUrl,
    );
    final bioController = TextEditingController(text: currentProfile.bio);
    final locationController = TextEditingController(
      text: currentProfile.location,
    );
    var isSaving = false;

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
                        TextField(
                          controller: displayNameController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: avatarUrlController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Avatar URL',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bioController,
                          enabled: !isSaving,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(labelText: 'Bio'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: locationController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Location',
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
                              final updatedProfile = await BackendApi.instance
                                  .updateUserProfile(
                                    displayName: displayNameController.text
                                        .trim(),
                                    avatarUrl: avatarUrlController.text.trim(),
                                    bio: bioController.text.trim(),
                                    location: locationController.text.trim(),
                                  );

                              final mergedProfile = UserProfile.fromJson({
                                ...updatedProfile.toJson(),
                                'token': user!.token,
                              });

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
      locationController.dispose();
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
        Center(
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
              child: profile.avatarUrl.isNotEmpty
                  ? Image.network(
                      profile.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
        ),
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
