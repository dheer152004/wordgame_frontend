import 'package:flutter/material.dart';
import '../../../models/profile_models.dart';
import '../../../theme/app_theme.dart';
import '../../profile/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final UserProfile? user;
  final VoidCallback? onSearchTap;

  const HomeHeader({super.key, this.user, this.onSearchTap});

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
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: user),
                      ),
                    )
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
                          errorBuilder: (_, __, ___) => Container(
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
                const SizedBox(height: 1),
                Text(
                  'Level ${user!.level} - ${user!.totalXp} XP',
                  style: AppTextStyles.greetingDate,
                ),
                const SizedBox(height: 1),
                Text(
                  '${user!.currentStreak} Day Streaks',
                  style: AppTextStyles.greetingDate,
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
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
