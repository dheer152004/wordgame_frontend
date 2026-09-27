import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../models/profile_models.dart';
import '../../services/session_store.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_action_buttons.dart';
import '../../widgets/settings_widgets.dart';
import 'package:share_plus/share_plus.dart';
import '../auth/auth_screen.dart';
import 'widgets/profile_saved_words_section.dart';
import 'saved_words_screen.dart';
import 'widgets/profile_badges_section.dart';
import 'widgets/profile_details_section.dart';
import 'widgets/profile_stats_section.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/profile_avatar_helper.dart';
import 'widgets/profile_report_dialog.dart';
import 'widgets/date_of_birth_dialog.dart';
import 'settings_detail_page.dart';

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
  bool _dateOfBirthPromptShown = false;
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
        if (profile.dateOfBirth == null && !_dateOfBirthPromptShown) {
          _dateOfBirthPromptShown = true;
          if (!context.mounted) {
            return;
          }
          final selectedDate = await showDialog<DateTime>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const DateOfBirthDialog(canSkip: true),
          );
          if (selectedDate != null && context.mounted) {
            setState(() {
              _profile = _profile?.copyWith(dateOfBirth: selectedDate);
            });
          }
        }
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
      backgroundColor: AppThemeColors.background(context),
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
                  Text(
                    'Profile',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
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
                  // onShowLocationNotice: () =>
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text('Location settings not implemented.'),
                  //       ),
                  //     ),
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
                    color: AppThemeColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppThemeColors.divider(context)),
                  ),
                  child: Text(
                    'Loading profile details...',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary(context),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppThemeColors.surface(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppThemeColors.divider(context)),
                  ),
                  child: Text(
                    'Log in to load profile details.',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary(context),
                    ),
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
              SettingsSection(
                title: 'Account',
                subtitle: 'Manage your account and sign-in settings.',
                children: [
                  SettingsTile(
                    title: 'Account',
                    icon: Icons.person_outline_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Account',
                      description: 'Account details and profile settings.',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Security',
                    icon: Icons.security_outlined,
                    onTap: () => _openSettingsPage(
                      title: 'Security',
                      description:
                          'Security settings will be connected to your account service.',
                      icon: Icons.security_outlined,
                    ),
                  ),
                  SettingsTile(
                    title: 'Delete Account',
                    icon: Icons.delete_outline_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Delete Account',
                      description:
                          'Account deletion functionality will be connected to your account service.',
                      icon: Icons.delete_outline_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Log Out',
                    icon: Icons.logout_rounded,
                    onTap: isSignedIn ? () => _logout(context) : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: 'Preferences',
                subtitle: 'Customize how NROQ works for you.',
                children: [
                  SettingsTile(
                    title: 'Language',
                    icon: Icons.language_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Language',
                      description:
                          'Language preferences will be available here.',
                      icon: Icons.language_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Notifications',
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Notifications',
                      description:
                          'Notification preferences will be connected to notification services.',
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                    onTap: () => _openSettingsPage(
                      title: 'Appearance',
                      description: 'Choose how NROQ looks on your device.',
                      icon: Icons.palette_outlined,
                      content: _appearanceControl(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: 'About',
                subtitle:
                    'Quick access to app information and sharing options.',
                children: [
                  SettingsTile(
                    title: 'About',
                    icon: Icons.info_outline_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'About',
                      description: 'Information about the NROQ app.',
                      icon: Icons.info_outline_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'App Version',
                    icon: Icons.rocket_launch_outlined,
                    onTap: () => _openSettingsPage(
                      title: 'App Version',
                      description: 'NROQ version information will appear here.',
                      icon: Icons.rocket_launch_outlined,
                    ),
                  ),
                  SettingsTile(
                    title: 'Rate App',
                    icon: Icons.star_outline_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Rate App',
                      description:
                          'App review functionality will be connected here.',
                      icon: Icons.star_outline_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Share App',
                    icon: Icons.share_outlined,
                    onTap: () => Share.share(
                      'Discover NROQ, your vocabulary learning companion.',
                      subject: 'NROQ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: 'Support',
                subtitle:
                    'Need help? Browse common questions or reach out to us directly.',
                children: [
                  SettingsTile(
                    title: 'FAQ',
                    icon: Icons.quiz_outlined,
                    onTap: () => _openSettingsPage(
                      title: 'FAQ',
                      description:
                          'Frequently asked questions will appear here.',
                      icon: Icons.quiz_outlined,
                    ),
                  ),
                  SettingsTile(
                    title: 'Contact Us',
                    icon: Icons.mail_outline_rounded,
                    onTap: () => _openSettingsPage(
                      title: 'Contact Us',
                      description: 'Contact options will be connected here.',
                      icon: Icons.mail_outline_rounded,
                    ),
                  ),
                  SettingsTile(
                    title: 'Report a Problem',
                    icon: Icons.report_problem_outlined,
                    onTap: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => const ProfileReportDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: 'Privacy & Legal',
                subtitle:
                    'Review the policies and terms that apply to your account.',
                children: [
                  SettingsTile(
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _openLegalLink(
                      Uri.parse('https://www.nroq.in/privacy-policy'),
                    ),
                  ),
                  SettingsTile(
                    title: 'Terms of Use',
                    icon: Icons.description_outlined,
                    onTap: () => _openLegalLink(
                      Uri.parse('https://www.nroq.in/terms-of-service'),
                    ),
                  ),
                  SettingsTile(
                    title: 'Consent Management',
                    icon: Icons.fact_check_outlined,
                    onTap: () => _openLegalLink(
                      Uri.parse('https://www.nroq.in/privacy-consent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: 'Other',
                children: [
                  SettingsTile(
                    title: 'Open Source Licenses',
                    icon: Icons.code_outlined,
                    onTap: () => showLicensePage(context: context),
                  ),
                ],
              ),
              if (!isSignedIn) ...[
                const SizedBox(height: 18),
                Text(
                  'Log in to manage your account settings.',
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
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

  void _openSettingsPage({
    required String title,
    required String description,
    required IconData icon,
    Widget? content,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsDetailPage(
          title: title,
          description: description,
          icon: icon,
          content: content,
        ),
      ),
    );
  }

  Future<void> _openLegalLink(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this page.')),
      );
    }
  }

  Widget _appearanceControl() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, selectedTheme, _) {
        return SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.settings_brightness_outlined),
            ),
          ],
          selected: {selectedTheme},
          onSelectionChanged: (selection) {
            themeNotifier.value = selection.first;
          },
        );
      },
    );
  }

  UserProfile _mergeAvatarPreference(UserProfile fetchedProfile) {
    return ProfileAvatarHelper.mergeAvatarPreference(fetchedProfile, user);
  }

  String _avatarSeed(UserProfile? profile) {
    return ProfileAvatarHelper.avatarSeed(profile);
  }
}
