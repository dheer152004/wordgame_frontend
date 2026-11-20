import 'package:flutter/material.dart';

import '../../../../models/profile_models.dart';
import '../../../../theme/app_theme.dart';

class ProfileBadgesSection extends StatelessWidget {
  final UserProfile profile;

  const ProfileBadgesSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
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
          accentColor:
              definition?.accentColor ?? AppThemeColors.challengeCard(context),
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
          earned: false,
        ),
      );
    }

    while (displayCards.length < targetCount) {
      displayCards.add(
        _BadgeGalleryEntry(
          label: 'Future badge',
          icon: Icons.lock_rounded,
          accentColor: AppThemeColors.textPrimary(context),
          earned: false,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges earned',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Earned badges stay bright. Locked badges stay muted until you unlock them.',
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: AppThemeColors.textSecondary(context),
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
                  earned: badge.earned,
                ),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_BadgeDefinition> _badgeDefinitions() {
    return const [
      _BadgeDefinition(
        label: 'Avoid puddles',
        alias: 'avoid puddles',
        icon: Icons.directions_walk_rounded,
        accentColor: Color(0xFF8EE6C7),
      ),
      _BadgeDefinition(
        label: 'Shake the tree',
        alias: 'shake the tree',
        icon: Icons.nature_rounded,
        accentColor: Color(0xFFA7F07D),
      ),
      _BadgeDefinition(
        label: 'Turn the mill',
        alias: 'turn the mill',
        icon: Icons.agriculture_rounded,
        accentColor: Color(0xFFF0D47A),
      ),
      _BadgeDefinition(
        label: 'Breathe slowly',
        alias: 'breathe slowly',
        icon: Icons.spa_rounded,
        accentColor: Color(0xFFF3A6B8),
      ),
      _BadgeDefinition(
        label: 'Jump high',
        alias: 'jump high',
        icon: Icons.self_improvement_rounded,
        accentColor: Color(0xFF9FD4FF),
      ),
      _BadgeDefinition(
        label: 'Count stars',
        alias: 'count stars',
        icon: Icons.star_rounded,
        accentColor: Color(0xFFFFD36A),
      ),
      _BadgeDefinition(
        label: 'Sleep well',
        alias: 'sleep well',
        icon: Icons.nightlight_round,
        accentColor: Color(0xFFC3B6FF),
      ),
    ];
  }
}

class _BadgeDefinition {
  final String label;
  final String alias;
  final IconData icon;
  final Color accentColor;

  const _BadgeDefinition({
    required this.label,
    required this.alias,
    required this.icon,
    required this.accentColor,
  });
}

class _BadgeGalleryEntry {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool earned;

  const _BadgeGalleryEntry({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.earned,
  });
}

class _BadgeGalleryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool earned;

  const _BadgeGalleryCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBody = Container(
      width: 76,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: earned
              ? accentColor.withAlpha(100)
              : AppThemeColors.divider(context),
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
              color: earned
                  ? accentColor.withAlpha(28)
                  : AppThemeColors.surface(context),
            ),
            child: Icon(
              icon,
              color: earned ? accentColor : AppThemeColors.textMuted(context),
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
              color: earned
                  ? AppThemeColors.textPrimary(context)
                  : AppThemeColors.textMuted(context),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: earned ? 1 : 0.55,
          duration: const Duration(milliseconds: 180),
          child: badgeBody,
        ),
        if (!earned)
          Positioned(
            right: 7,
            top: 7,
            child: Icon(
              Icons.lock_rounded,
              size: 13,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
      ],
    );
  }
}
