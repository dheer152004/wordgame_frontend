import 'package:flutter/material.dart';
import '../../../models/profile_models.dart';
import '../../../theme/app_theme.dart';
import '../../profile/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final UserProfile? user;
  final VoidCallback? onSearchTap;
  final Future<void> Function()? onProfileReturned;

  const HomeHeader({
    super.key,
    this.user,
    this.onSearchTap,
    this.onProfileReturned,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  // String _formatDate(DateTime date) {
  //   const months = [
  //     'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December',
  //   ];

  //   return '${date.day} ${months[date.month - 1]}';
  // }

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = user != null && user!.greetingName.isNotEmpty;
    final displayName = hasDisplayName ? user!.greetingName : 'there';
    final hasAvatar = user != null && user!.avatarUrl.isNotEmpty;
    final lastQuizDate = user == null
        ? null
        : DateTime.tryParse(user!.lastQuizDate)?.toLocal();
    final today = DateTime.now();
    final streakCompletedToday =
        lastQuizDate != null &&
        lastQuizDate.year == today.year &&
        lastQuizDate.month == today.month &&
        lastQuizDate.day == today.day;

    return Row(
      children: [
        Tooltip(
          message: 'Open profile',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: user != null
                  ? () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: user),
                        ),
                      );
                      if (context.mounted) {
                        await onProfileReturned?.call();
                      }
                    }
                  : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.challengeCard,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasAvatar
                      ? Image.network(
                          user!.avatarUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.challengeCard,
                            alignment: Alignment.center,
                            child: const Text(
                              'Not shown',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.challengeCard,
                          alignment: Alignment.center,
                          child: Text(
                            _initials(displayName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello $displayName', style: AppTextStyles.greeting),
              const SizedBox(height: 1),
              if (user != null) ...[
                const SizedBox(height: 7),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _HomeStatPill(
                        icon: streakCompletedToday
                            ? Icons.local_fire_department_rounded
                            : Icons.local_fire_department_outlined,
                        iconColor: streakCompletedToday
                            ? AppColors.streak
                            : AppThemeColors.textMuted(context),
                        label: '${user!.currentStreak}',
                      ),
                      _HomeStatPill(
                        icon: Icons.hexagon_rounded,
                        iconColor: AppThemeColors.textSecondary(context),
                        label: 'Level ${user!.level}  ·  ${user!.totalXp} XP',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onSearchTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppThemeColors.textPrimary(context),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeStatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _HomeStatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
