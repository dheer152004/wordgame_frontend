import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../models/profile_models.dart';
import '../../services/session_store.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';
import 'widgets/profile_badges_section.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/profile_avatar_helper.dart';
import 'widgets/profile_report_dialog.dart';
import 'widgets/date_of_birth_dialog.dart';
import 'widgets/profile_saved_words_section.dart';
import 'widgets/profile_account_section.dart';
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
  bool _accountDetailsExpanded = false;
  bool _notificationsEnabled = true;
  final String _selectedLanguage = 'English (US)';
  bool _dateOfBirthPromptShown = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _restoreSessionUser();
  }

  Future<void> _restoreSessionUser() async {
    user ??= await SessionStore.restoreUser();
    _fetchProfile();
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
      final savedDateOfBirth = (await SessionStore.restoreUser())?.dateOfBirth;
      final dateOfBirth = profile.dateOfBirth ?? savedDateOfBirth;
      if (mounted) {
        setState(() {
          _profile = _mergeAvatarPreference(
            profile,
          ).copyWith(dateOfBirth: dateOfBirth);
          _loadingProfile = false;
        });
        if (dateOfBirth == null && !_dateOfBirthPromptShown) {
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

  Future<void> _logout(BuildContext context) async {
    try {
      await BackendApi.instance.logout();
    } catch (_) {
      await SessionStore.clear();
    }
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
    final profile = _profile ?? user;
    final displayName = profile == null
        ? 'Guest'
        : profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.username;
    final level = profile?.level ?? 1;
    final totalXp = profile?.totalXp ?? 0;
    final xpToNextLevel = profile?.xpToNextLevel ?? 0;
    final nextLevelXp = totalXp + xpToNextLevel;
    final levelProgress = profile == null || profile.levelProgress <= 0
        ? (nextLevelXp == 0 ? 0.0 : totalXp / nextLevelXp)
        : profile.levelProgress / 100;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppThemeColors.textPrimary(context),
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Appearance settings',
                    onPressed: () => _openSettingsPage(
                      title: 'Appearance',
                      description: 'Choose how NROQ looks on your device.',
                      icon: LucideIcons.sunMoon,
                      content: _appearanceControl(),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppThemeColors.surfaceAlt(context),
                      foregroundColor: AppThemeColors.textSecondary(context),
                    ),
                    icon: const Icon(LucideIcons.settings, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (profile == null && _loadingProfile)
                const LinearProgressIndicator(minHeight: 2),
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _profileAvatar(
                          ProfileAvatarHelper.resolveAvatarUrl(_profile, user),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: AppThemeColors.primary(context),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: isSignedIn ? _editProfile : null,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  LucideIcons.pencil,
                                  size: 12,
                                  color: AppThemeColors.textOnPrimary(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName.isEmpty ? 'Guest' : displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.email ?? 'Sign in to manage your profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _levelProgressCard(
                level: level,
                totalXp: totalXp,
                nextLevelXp: nextLevelXp,
                xpToNextLevel: xpToNextLevel,
                progress: levelProgress.clamp(0.0, 1.0),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metricTile(
                      icon: LucideIcons.bookOpen,
                      color: const Color(0xFF686BFF),
                      value: '${profile?.totalWordsSaved ?? 0}',
                      label: 'Words Learned',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricTile(
                      icon: LucideIcons.flame,
                      color: const Color(0xFFFF762B),
                      value: '${profile?.currentStreak ?? 0}',
                      label: 'Day Streak',
                    ),
                  ),
                ],
              ),
              if (isSignedIn) ...[
                const SizedBox(height: 12),
                const ProfileSavedWordsSection(),
              ],
              const SizedBox(height: 18),
              _sectionLabel(context, 'ACCOUNT OPTIONS'),
              const SizedBox(height: 6),
              _settingsGroup([
                _ProfileOptionRow(
                  icon: LucideIcons.user,
                  iconColor: const Color(0xFF4A8CFF),
                  title: 'Account Details',
                  trailing: Icon(
                    _accountDetailsExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 15,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  onTap: () => setState(
                    () => _accountDetailsExpanded = !_accountDetailsExpanded,
                  ),
                ),
                if (_accountDetailsExpanded) _accountDetails(context, profile),
                _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.globe,
                  iconColor: const Color(0xFF19C66A),
                  title: 'Language',
                  value: _selectedLanguage,
                  trailing: Icon(
                    LucideIcons.chevronDown,
                    size: 15,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  onTap: _chooseLanguage,
                ),
                _divider(context),

                // _ProfileOptionRow(
                //   icon: LucideIcons.target,
                //   iconColor: const Color(0xFFA655F5),
                //   title: 'Daily Goals & Streak',
                //   trailing: Icon(
                //     LucideIcons.chevronDown,
                //     size: 15,
                //     color: AppThemeColors.textSecondary(context),
                //   ),
                //   onTap: () => _openSettingsPage(
                //     title: 'Daily Goals & Streak',
                //     description:
                //         'Your current streak is ${profile?.currentStreak ?? 0} days. Keep learning daily to build it up.',
                //     icon: LucideIcons.target,
                //   ),
                // ),
                // _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.award,
                  iconColor: const Color(0xFFFF8B27),
                  title: 'Achievements & Badges',
                  trailing: Icon(
                    LucideIcons.chevronDown,
                    size: 15,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  onTap: () => _openSettingsPage(
                    title: 'Achievements & Badges',
                    description: 'Badges you have earned so far.',
                    icon: LucideIcons.award,
                    content: _profile == null
                        ? null
                        : ProfileBadgesSection(profile: _profile!),
                  ),
                ),
                _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.bell,
                  iconColor: const Color(0xFFFF536A),
                  title: 'Notifications',
                  trailing: _profileSwitch(
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                ),
                _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.moon,
                  iconColor: const Color(0xFF7776FF),
                  title: 'Dark Mode',
                  trailing: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, _) => _profileSwitch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (enabled) {
                        themeNotifier.value = enabled
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      },
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _sectionLabel(context, 'MORE'),
              const SizedBox(height: 6),
              _settingsGroup([
                _ProfileOptionRow(
                  icon: LucideIcons.helpCircle,
                  iconColor: const Color(0xFFFFA400),
                  title: 'Help & Support',
                  trailing: Icon(
                    LucideIcons.chevronDown,
                    size: 15,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  onTap: _showSupportOptions,
                ),
                _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.shieldCheck,
                  iconColor: const Color(0xFF12CDB4),
                  title: 'Data & Privacy',
                  trailing: Icon(
                    LucideIcons.chevronDown,
                    size: 15,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  onTap: _showPrivacyOptions,
                ),
                _divider(context),
                _ProfileOptionRow(
                  icon: LucideIcons.logOut,
                  iconColor: const Color(0xFFFF5964),
                  title: 'Log Out',
                  titleColor: const Color(0xFFE5484D),
                  onTap: isSignedIn ? () => _logout(context) : null,
                ),
              ]),
              if (!isSignedIn) ...[
                const SizedBox(height: 12),
                Text(
                  'Log in to manage your account settings.',
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 12,
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

    if (!mounted) {
      return;
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
              icon: Icon(LucideIcons.sun),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(LucideIcons.moon),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(LucideIcons.sunMoon),
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

  Widget _profileAvatar(String avatarUrl) {
    final borderColor = AppThemeColors.divider(context);
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? ColoredBox(
                color: AppThemeColors.surfaceAlt(context),
                child: Icon(
                  LucideIcons.user,
                  size: 28,
                  color: AppThemeColors.textSecondary(context),
                ),
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: AppThemeColors.surfaceAlt(context),
                  child: Icon(
                    LucideIcons.user,
                    size: 28,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _levelProgressCard({
    required int level,
    required int totalXp,
    required int nextLevelXp,
    required int xpToNextLevel,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$totalXp / $nextLevelXp XP',
                style: TextStyle(
                  color: AppThemeColors.primary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? DarkColors.progressBackground
                  : LightColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeColors.primary(context),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$xpToNextLevel XP to reach Level ${level + 1}',
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(
        label,
        style: TextStyle(
          color: AppThemeColors.textSecondary(context),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: 48,
    endIndent: 0,
    color: AppThemeColors.divider(context),
  );

  Widget _profileSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      activeTrackColor: const Color(0xFFF43F63),
      inactiveTrackColor: AppThemeColors.divider(context),
      inactiveThumbColor: AppThemeColors.surface(context),
      trackOutlineColor: WidgetStatePropertyAll(
        AppThemeColors.divider(context),
      ),
    );
  }

  Widget _accountDetails(BuildContext context, UserProfile? profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 12),
      child: Column(
        children: [
          _accountValue(context, 'Username', profile?.username ?? 'Guest'),
          _accountValue(context, 'Email', profile?.email ?? 'Not signed in'),
          _accountValue(
            context,
            'Member Since',
            _memberSince(profile?.createdAt),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: user == null ? null : _editProfile,
              icon: const Icon(LucideIcons.pencil, size: 14),
              label: const Text('Edit profile'),
              style: TextButton.styleFrom(
                foregroundColor: AppThemeColors.primary(context),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountValue(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 10,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppThemeColors.textPrimary(context),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _memberSince(DateTime? date) {
    if (date == null) return 'Unknown';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  void _chooseLanguage() {
    _openSettingsPage(
      title: 'Language',
      description: 'Language preferences will be available here.',
      icon: LucideIcons.globe,
    );
  }

  void _showSupportOptions() {
    _openSettingsPage(
      title: 'Help & Support',
      description: 'Find help or contact the NROQ team.',
      icon: LucideIcons.helpCircle,
      content: Column(
        children: [
          _detailAction(
            icon: LucideIcons.helpCircle,
            label: 'Frequently Asked Questions',
            onTap: () => _openLegalLink(Uri.parse('https://www.nroq.in/faq')),
          ),
          _detailAction(
            icon: LucideIcons.mail,
            label: 'Contact Us',
            onTap: () => _openLegalLink(Uri.parse('mailto:mail@nroq.in')),
          ),
          _detailAction(
            icon: LucideIcons.flag,
            label: 'Report a Problem',
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => const ProfileReportDialog(),
            ),
          ),
          _detailAction(
            icon: LucideIcons.trash2,
            label: 'Delete your account',
            color: Theme.of(context).colorScheme.error,
            onTap: user != null ? _showDeleteAccountDialog : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => ProfileDeleteAccountDialog(
        onDelete: (reason) async {
          await BackendApi.instance.deleteUserAccount(reason: reason);
          await SessionStore.clear();
        },
      ),
    );

    if (deleted == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  void _showPrivacyOptions() {
    _openSettingsPage(
      title: 'Data & Privacy',
      description: 'Review how your account data is handled.',
      icon: LucideIcons.shieldCheck,
      content: Column(
        children: [
          _detailAction(
            icon: LucideIcons.shieldCheck,
            label: 'Privacy Policy',
            onTap: () =>
                _openLegalLink(Uri.parse('https://www.nroq.in/privacy-policy')),
          ),
          _detailAction(
            icon: LucideIcons.fileText,
            label: 'Terms of Use',
            onTap: () => _openLegalLink(
              Uri.parse('https://www.nroq.in/terms-of-service'),
            ),
          ),
          _detailAction(
            icon: LucideIcons.checkCircle,
            label: 'Consent Management',
            onTap: () => _openLegalLink(
              Uri.parse('https://www.nroq.in/privacy-consent'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    final actionColor = color ?? AppThemeColors.primary(context);
    return ListTile(
      leading: Icon(icon, size: 19, color: actionColor),
      title: Text(
        label,
        style: color == null ? null : TextStyle(color: actionColor),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }

  UserProfile _mergeAvatarPreference(UserProfile fetchedProfile) {
    return ProfileAvatarHelper.mergeAvatarPreference(fetchedProfile, user);
  }

  String _avatarSeed(UserProfile? profile) {
    return ProfileAvatarHelper.avatarSeed(profile);
  }
}

class _ProfileOptionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileOptionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withAlpha(24),
                  ),
                  child: Icon(icon, size: 13, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor ?? AppThemeColors.textPrimary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
                if (trailing != null) ...[const SizedBox(width: 6), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
