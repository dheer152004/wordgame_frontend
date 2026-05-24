import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final UserProfile? user;

  const HomeHeader({super.key, this.user});

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
        Container(
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
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.white, size: 24),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 24),
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

        Container(
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
      ],
    );
  }
}
