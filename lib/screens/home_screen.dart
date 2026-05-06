import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/week_day_picker.dart';
import '../widgets/your_plan_section.dart';
import '../widgets/home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar icons dark (for light background)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // iOS
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 16),

                    // 1. Header: avatar + greeting + search
                    HomeHeader(),
                    SizedBox(height: 24),

                    // 2. Daily challenge card
                    DailyChallengeCard(),
                    SizedBox(height: 24),

                    // 3. Week day picker
                    WeekDayPicker(),
                    SizedBox(height: 28),

                    // 4. Categories section
                    CategoriesSection(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 5. Bottom navigation bar (fixed)
            const HomeBottomNav(),
          ],
        ),
      ),
    );
  }
}
