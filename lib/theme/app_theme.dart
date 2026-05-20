import 'package:flutter/material.dart';

// Dark Mode Colors
class DarkColors {
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

// Light Mode Colors
class LightColors {
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF5F7FB);
  static const Color surfaceSoft = Color(0xFFEEF1F6);
  static const Color challengeCard = Color(0xFF6677FF);
  static const Color planCardYellow = Color(0xFFD4D913);
  static const Color planCardBlue = Color(0xFF4BA3D0);
  static const Color planCardPink = Color(0xFFE54B8C);
  static const Color accentCyan = Color(0xFF0BA8C8);
  static const Color accentViolet = Color(0xFF6B5BA8);
  static const Color accentLime = Color(0xFFD4D913);
  static const Color accentPink = Color(0xFFE54B8C);
  static const Color textPrimary = Color(0xFF0B0E15);
  static const Color textSecondary = Color(0xFF5A6580);
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color navBackground = Color(0xFFF8F9FB);
  static const Color navActive = Color(0xFF0B0E15);
  static const Color navInactive = Color(0xFF8D96A8);
  static const Color daySelected = Color(0xFF0B0E15);
  static const Color dayUnselected = Color(0xFFF5F7FB);
  static const Color dayDot = Color(0xFFD4D913);
  static const Color tagBg = Color(0x1A0B0E15);
}

// Default colors (for backward compatibility)
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

// Theme Data
class AppTheme {
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkColors.background,
      primaryColor: DarkColors.accentCyan,
      canvasColor: DarkColors.surface,
      cardColor: DarkColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: DarkColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.sectionTitle,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DarkColors.navBackground,
        selectedItemColor: DarkColors.navActive,
        unselectedItemColor: DarkColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        surface: DarkColors.surface,
        background: DarkColors.background,
        primary: DarkColors.accentCyan,
        secondary: DarkColors.accentViolet,
        tertiary: DarkColors.accentLime,
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.background,
      primaryColor: LightColors.accentCyan,
      canvasColor: LightColors.surface,
      cardColor: LightColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: LightColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.sectionTitle,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LightColors.navBackground,
        selectedItemColor: LightColors.navActive,
        unselectedItemColor: LightColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      colorScheme: ColorScheme.light(
        surface: LightColors.surface,
        background: LightColors.background,
        primary: LightColors.accentCyan,
        secondary: LightColors.accentViolet,
        tertiary: LightColors.accentLime,
      ),
    );
  }
}
