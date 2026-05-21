import 'package:flutter/material.dart';

import '../main.dart';
import '../models/auth_models.dart';
import '../services/backend_api.dart';
import '../services/session_store.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AuthUser? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthUser? user;
  dynamic _quizStats;
  bool _loadingStats = false;
  dynamic _cachedQuizStats;
  DateTime? _cacheTime;
  static const Duration _cacheExpiration = Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _fetchQuizStats();
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
    final displayName = isSignedIn && user!.greetingName.isNotEmpty
        ? user!.greetingName
        : 'Guest';
    final subtitle = isSignedIn
        ? 'Your account details and learning stats'
        : 'You are browsing as a guest';

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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(90),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
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
                          ),
                          child: ClipOval(
                            child: isSignedIn && user!.avatarUrl.isNotEmpty
                                ? Image.network(
                                    user!.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 34,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(subtitle, style: AppTextStyles.greetingDate),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoTile(
                      label: 'Username',
                      value: isSignedIn ? user!.username : 'Guest',
                    ),
                    _InfoTile(
                      label: 'Email',
                      value: isSignedIn ? user!.email : 'Not signed in',
                    ),
                    _InfoTile(
                      label: 'Display name',
                      value: isSignedIn && user!.displayName.isNotEmpty
                          ? user!.displayName
                          : 'Not set',
                    ),
                    _InfoTile(
                      label: 'User ID',
                      value: isSignedIn ? user!.id.toString() : '-',
                    ),
                    _InfoTile(
                      label: 'Level',
                      value: isSignedIn ? user!.level.toString() : '-',
                    ),
                    _InfoTile(
                      label: 'Total XP',
                      value: isSignedIn ? user!.totalXp.toString() : '-',
                    ),
                    _InfoTile(
                      label: 'Current streak',
                      value: isSignedIn ? '${user!.currentStreak} day(s)' : '-',
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
