import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/profile_models.dart';
import 'package:nroq/screens/profile/settings_detail_page.dart';
import 'package:nroq/screens/profile/widgets/profile_badges_section.dart';

void main() {
  testWidgets('achievement detail page renders with both profile themes', (
    tester,
  ) async {
    final profile = UserProfile.fromJson({
      'recentBadges': ['Count stars'],
    });

    for (final theme in [ThemeData.light(), ThemeData.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: SettingsDetailPage(
            title: 'Achievements & Badges',
            description: 'Badges you have earned so far.',
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFFF8B27),
            content: ProfileBadgesSection(profile: profile),
          ),
        ),
      );

      expect(find.text('Achievements & Badges'), findsOneWidget);
      expect(find.text('Badges earned'), findsOneWidget);
      expect(find.text('Count stars'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
