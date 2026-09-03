import 'package:flutter/material.dart';
import '../../../models/profile_models.dart';
import '../../flash_cards_screen.dart';
import '../../quiz/quiz_screen.dart';
import '../../profile/profile_screen.dart';
import '../../../theme/app_theme.dart';

class HomeBottomNav extends StatefulWidget {
  final UserProfile? user;

  const HomeBottomNav({super.key, this.user});

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
            onTap: () {
              setState(() => _selectedIndex = index);

              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FlashCardsScreen()),
                );
              }

              if (index == 2) {
                openQuizModePicker(context);
              }

              if (index == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.user),
                  ),
                );
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
