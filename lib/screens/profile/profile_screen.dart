import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/profile_models.dart';
import '../../services/session_store.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_action_buttons.dart';
import '../auth/auth_screen.dart';
import 'widgets/profile_saved_words_section.dart';
import 'saved_words_screen.dart';
import 'widgets/profile_badges_section.dart';
import 'widgets/profile_details_section.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/profile_stats_section.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/profile_AppInfo_section.dart';
import 'widgets/profile_legal_section.dart';
import 'widgets/profile_Support_section.dart';
import 'widgets/profile_password_dialog.dart';
import 'widgets/profile_avatar_helper.dart';
import 'widgets/profile_report_dialog.dart';

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
              if (_profile != null)
                ProfileDetailsSection(
                  profile: _profile!,
                  isSignedIn: isSignedIn,
                  isLoadingProfile: _loadingProfile,
                  onEditProfile: _editProfile,
                  onRefreshProfile: () => _fetchProfile(),
                  onOpenSavedWords: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => SavedWordsScreen())),
                  onClearCache: () async {
                    await SessionStore.clearCache();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared.')),
                    );
                  },
                  onClearHistory: () async {
                    await SessionStore.clearHistory();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History cleared.')),
                    );
                  },
                  onShowLocationNotice: () =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location settings not implemented.'),
                        ),
                      ),
                  resolvedAvatarUrl: ProfileAvatarHelper.resolveAvatarUrl(
                    _profile,
                    user,
                  ),
                )
              else if (isSignedIn)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: const Text(
                    'Loading profile details...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: const Text(
                    'Log in to load profile details.',
                    style: TextStyle(color: AppColors.textSecondary),
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
                ProfileStatsSection(
                  stats: _quizStats,
                  onRefresh: () => _fetchQuizStats(forceRefresh: true),
                ),
                const SizedBox(height: 18),
                if (_profile != null && _profile!.recentBadges.isNotEmpty) ...[
                  ProfileBadgesSection(profile: _profile!),
                  const SizedBox(height: 18),
                ],
              ],
              ProfileSettingsSection(
                selectedTheme: themeNotifier.value,
                onThemeChanged: (themeMode) {
                  setState(() {
                    themeNotifier.value = themeMode;
                  });
                },
              ),
              const SizedBox(height: 18),
              ProfileAppInfoSection(
                onAboutTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About section coming soon.')),
                ),
                onAppVersionTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App version details coming soon.'),
                      ),
                    ),
                onRateAppTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rate app action coming soon.')),
                ),
                onShareAppTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share app action coming soon.'),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ProfileSupportSection(
                onFAQTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ will be added soon.')),
                ),
                onContactUsTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact us will be added soon.'),
                      ),
                    ),
                onReportProblemTap: () async {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => const ProfileReportDialog(),
                  );
                },
              ),
              const SizedBox(height: 18),
              ProfileLegalSection(
                onPrivacyPolicyTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy will be added soon.'),
                      ),
                    ),
                onTermsOfUseTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of Use will be added soon.'),
                      ),
                    ),
                onConsentmanagement: _openConsentManagement,
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

    final avatarSeed = _avatarSeed(currentProfile);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ProfileEditDialog(
          currentProfile: currentProfile,
          existingUser: user,
          avatarSeed: avatarSeed,
          avatarStyles: ProfileAvatarHelper.diceBearAvatarStyles,
          buildAvatarUrl: ProfileAvatarHelper.buildDiceBearAvatarUrl,
          diceBearStyleFromUrl: ProfileAvatarHelper.diceBearStyleFromUrl,
          onProfileUpdated: (mergedProfile) async {
            if (!mounted) {
              return;
            }

            setState(() {
              _profile = mergedProfile;
              user = mergedProfile;
            });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
          },
        );
      },
    );
  }

  Future<void> _changePassword() async {
    if (user == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const ProfilePasswordDialog();
      },
    );
  }

  Future<void> _openConsentManagement() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view your consents.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.82,
        child: _ConsentManagementSheet(formatDateTime: _formatDateTime),
      ),
    );
  }

  UserProfile _mergeAvatarPreference(UserProfile fetchedProfile) {
    return ProfileAvatarHelper.mergeAvatarPreference(fetchedProfile, user);
  }

  String _resolvedAvatarUrl(UserProfile? profile) {
    return ProfileAvatarHelper.resolveAvatarUrl(profile, user);
  }

  String _avatarSeed(UserProfile? profile) {
    return ProfileAvatarHelper.avatarSeed(profile);
  }

  String _buildDiceBearAvatarUrl({
    required String style,
    required String seed,
  }) {
    return ProfileAvatarHelper.buildDiceBearAvatarUrl(style: style, seed: seed);
  }

  String? _diceBearStyleFromUrl(String value) {
    return ProfileAvatarHelper.diceBearStyleFromUrl(value);
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

class _ConsentManagementSheet extends StatefulWidget {
  final String Function(DateTime?) formatDateTime;

  const _ConsentManagementSheet({required this.formatDateTime});

  @override
  State<_ConsentManagementSheet> createState() =>
      _ConsentManagementSheetState();
}

class _ConsentManagementSheetState extends State<_ConsentManagementSheet> {
  late Future<List<UserConsent>> _futureConsents;

  @override
  void initState() {
    super.initState();
    _futureConsents = BackendApi.instance.fetchUserConsents();
  }

  void _reload() {
    setState(() {
      _futureConsents = BackendApi.instance.fetchUserConsents();
    });
  }

  Color _statusColor(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized == 'GRANTED') {
      return const Color(0xFF36C68A);
    }
    if (normalized == 'WITHDRAWN') {
      return const Color(0xFFFF8C7A);
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Consent Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Your consent history with document title, status, accepted time, and source.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<UserConsent>>(
                future: _futureConsents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load consents',
                            style: TextStyle(
                              color: AppColors.textPrimary.withAlpha(220),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _reload,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final consents = snapshot.data ?? const <UserConsent>[];
                  if (consents.isEmpty) {
                    return const Center(
                      child: Text(
                        'No consent records found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: consents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final consent = consents[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withAlpha(16)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consent.legalDocumentTitle.isNotEmpty
                                  ? consent.legalDocumentTitle
                                  : consent.legalDocumentType,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ConsentDetailRow(
                              label: 'Status',
                              value: consent.status,
                              valueColor: _statusColor(consent.status),
                            ),
                            const SizedBox(height: 6),
                            _ConsentDetailRow(
                              label: 'Accepted At',
                              value: widget.formatDateTime(consent.acceptedAt),
                            ),
                            const SizedBox(height: 6),
                            _ConsentDetailRow(
                              label: 'Accepted From',
                              value: consent.acceptedFrom.isNotEmpty
                                  ? consent.acceptedFrom
                                  : 'Unknown',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ConsentDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
