import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B0E15);
  static const Color surface = Color(0xFF151B28);
  static const Color surfaceAlt = Color(0xFF1B2334);
  static const Color surfaceSoft = Color(0xFF222B3E);
  static const Color challengeCard = Color(0xFF6677FF);
  static const Color planCardYellow = Color(0xFFE5F14A);
  static const Color planCardBlue = Color(0xFF7BC5FF);
  static const Color planCardPink = Color(0xFFFF79CC);
  static const Color accentCyan = Color(0xFF5BE7FF);
  static const Color accentViolet = Color(0xFF8A7DFF);
  static const Color accentLime = Color(0xFFE5F14A);
  static const Color accentPink = Color(0xFFFF79CC);
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFFA7B0C5);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color navBackground = Color(0xFF111723);
  static const Color navActive = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF73809A);
  static const Color daySelected = Color(0xFFF4F7FF);
  static const Color dayUnselected = Color(0xFF151B28);
  static const Color dayDot = Color(0xFFE5F14A);
  static const Color tagBg = Color(0x1AF4F7FF);
}

class AppTextStyles {
  static const String fontFamily = 'SF Pro Display';

  static const TextStyle greeting = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle greetingDate = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle challengeTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const TextStyle challengeSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle planCardTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle planCardDetail = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle tagText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle trainerLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle trainerName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle dayLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static const TextStyle dayNumber = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
}

class AppRadius {
  static const double card = 24.0;
  static const double cardSmall = 16.0;
  static const double pill = 100.0;
  static const double tag = 100.0;
  static const double avatar = 100.0;
  static const double navBar = 32.0;
}

class AppSpacing {
  static const double screenPadding = 20.0;
  static const double cardGap = 12.0;
  static const double sectionGap = 24.0;
}
