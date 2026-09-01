import 'package:flutter/material.dart';

import '../../../../models/profile_models.dart';
import '../../../../theme/app_theme.dart';
import 'profile_avatar_preview.dart';

class ProfileDetailsSection extends StatelessWidget {
  final UserProfile profile;
  final bool isSignedIn;
  final bool isLoadingProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onRefreshProfile;
  final VoidCallback onOpenSavedWords;
  final VoidCallback onClearCache;
  final VoidCallback onClearHistory;
  final VoidCallback onShowLocationNotice;
  final String resolvedAvatarUrl;

  const ProfileDetailsSection({
    super.key,
    required this.profile,
    required this.isSignedIn,
    required this.isLoadingProfile,
    required this.onEditProfile,
    required this.onRefreshProfile,
    required this.onOpenSavedWords,
    required this.onClearCache,
    required this.onClearHistory,
    required this.onShowLocationNotice,
    required this.resolvedAvatarUrl,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Profile Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: isSignedIn ? onEditProfile : null,
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit profile',
                    iconSize: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  if (isLoadingProfile)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      onPressed: isSignedIn ? onRefreshProfile : null,
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
          _buildProfileDetails(context),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileAvatarPreview(avatarUrl: resolvedAvatarUrl),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.bio.isNotEmpty ? profile.bio : 'No bio',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: isSignedIn ? onEditProfile : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeColors.challengeCard(context),
                        foregroundColor: AppThemeColors.textOnPrimary(context),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MetricCard(label: 'Level', value: profile.level.toString()),
            const SizedBox(width: 8),
            _MetricCard(label: 'XP', value: profile.totalXp.toString()),
            const SizedBox(width: 8),
            _MetricCard(
              label: 'Mastered',
              value: profile.wordsMastered.toString(),
            ),
            const SizedBox(width: 8),
            _MetricCard(
              label: 'Avg Quiz',
              value: profile.averageQuizScore.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _InfoTile(label: 'Username', value: profile.username),
        _InfoTile(label: 'Email', value: profile.email),
        _InfoTile(label: 'Bio', value: _displayValue(profile.bio)),
        _InfoTile(label: 'Location', value: _displayValue(profile.location)),
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
        const SizedBox(height: 18),
        Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        _QuickActionTile(
          icon: Icons.favorite_border,
          label: 'Saved words',
          subtitle: '${profile.totalWordsSaved} saved',
          onTap: onOpenSavedWords,
        ),
        _QuickActionTile(
          icon: Icons.location_on_outlined,
          label: 'Location',
          subtitle: profile.location.isNotEmpty ? profile.location : 'Unknown',
          onTap: onShowLocationNotice,
        ),
        _QuickActionTile(
          icon: Icons.clear_all_rounded,
          label: 'Clear cache',
          subtitle: 'Free up storage',
          onTap: onClearCache,
        ),
        _QuickActionTile(
          icon: Icons.history_toggle_off_rounded,
          label: 'Clear history',
          subtitle: 'Remove local activity',
          onTap: onClearHistory,
        ),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppThemeColors.chipBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppThemeColors.divider(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppThemeColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
        color: AppThemeColors.chipBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeColors.chipBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppThemeColors.primary(context).withAlpha(28),
          child: Icon(icon, color: AppThemeColors.primary(context)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: AppThemeColors.textSecondary(context)),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppThemeColors.textSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
