import 'package:flutter/material.dart';
import '../../../models/profile_models.dart';
import '../../../models/quiz_models.dart';
import '../../flash_cards_screen.dart';
import '../../quiz/quiz_screen.dart';
import '../../profile/profile_screen.dart';
import '../../../theme/app_theme.dart';

class HomeBottomNav extends StatefulWidget {
  final UserProfile? user;
  final Future<void> Function()? onProfileReturned;
  final ValueChanged<QuizSubmissionResult>? onQuizCompleted;

  const HomeBottomNav({
    super.key,
    this.user,
    this.onProfileReturned,
    this.onQuizCompleted,
  });

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  int _selectedIndex = 0;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.track_changes_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.navBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.navBar),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (index) {
          final isActive = index == _selectedIndex;
          return GestureDetector(
            onTap: () async {
              setState(() => _selectedIndex = index);

              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FlashCardsScreen()),
                );
              }

              if (index == 2) {
                final quizResult = await openQuizModePicker(context);
                if (context.mounted) {
                  await widget.onProfileReturned?.call();
                  if (context.mounted && quizResult != null) {
                    widget.onQuizCompleted?.call(quizResult);
                  }
                }
              }

              if (index == 3) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.user),
                  ),
                );
                if (context.mounted) {
                  await widget.onProfileReturned?.call();
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icons[index],
                size: 24,
                color: isActive
                    ? AppThemeColors.navActive(context)
                    : AppThemeColors.navInactive(context),
              ),
            ),
          );
        }),
      ),
    );
  }
}
