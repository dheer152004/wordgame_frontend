import 'dart:ui' as ui;

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
          backgroundColor:
              definition?.backgroundColor ??
              AppThemeColors.challengeCard(context).withAlpha(56),
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
          accentColor: AppThemeColors.textPrimary(context),
          backgroundColor: AppThemeColors.surface(context).withAlpha(140),
          earned: false,
        ),
      );
    }

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
            'Earned badges stay bright. Locked badges stay blurred until you unlock them.',
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
        color: earned ? backgroundColor : AppThemeColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: earned
              ? accentColor.withAlpha(140)
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
              color: earned ? null : AppThemeColors.surfaceAlt(context),
            ),
            child: Icon(
              icon,
              color: earned
                  ? AppThemeColors.textOnPrimary(context)
                  : AppThemeColors.textMuted(context),
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
                  : AppThemeColors.textSecondary(context),
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
                        color: AppThemeColors.overlay(context).withAlpha(24),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 15,
                      color: AppThemeColors.textOnPrimary(
                        context,
                      ).withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
    );

    return Padding(padding: const EdgeInsets.only(right: 0), child: content);
  }
}
