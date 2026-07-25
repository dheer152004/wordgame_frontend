import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileSettingsSection extends StatelessWidget {
  final ThemeMode selectedTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ProfileSettingsSection({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                selected: <ThemeMode>{selectedTheme},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  onThemeChanged(newSelection.first);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
