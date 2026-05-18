import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/auth_models.dart';
import '../theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/mascot/animated_mascot_card.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/week_day_picker.dart';
import '../widgets/your_plan_section.dart';
import '../widgets/home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  final AuthUser? user;

  const HomeScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Make status bar icons dark (for light background)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
                  children: [
                    const SizedBox(height: 16),
                    HomeHeader(user: user),
                    const SizedBox(height: 24),
                    AnimatedMascotCard(userName: user?.greetingName),
                    const SizedBox(height: 24),
                    const DailyChallengeCard(),
                    const SizedBox(height: 24),
                    const WeekDayPicker(),
                    const SizedBox(height: 28),
                    const CategoriesSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 5. Bottom navigation bar (fixed)
            HomeBottomNav(user: user),
          ],
        ),
      ),
    );
  }
}
