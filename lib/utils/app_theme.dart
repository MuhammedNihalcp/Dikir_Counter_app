import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  // Accent palette
  static const Color emerald = Color(0xFF10B981);
  static const Color forest = Color(0xFF16A34A);
  static const Color gold = Color(0xFFF59E0B);
  static const Color sapphire = Color(0xFF3B82F6);
  static const Color rose = Color(0xFFEC4899);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color crimson = Color(0xFFEF4444);
  static const Color cyan = Color(0xFF06B6D4);

  // Dark
  static const Color darkBg = Color(0xFF07100D);
  static const Color darkSurface = Color(0xFF0F1A15);
  static const Color darkCard = Color(0xFF162019);
  static const Color darkBorder = Color(0xFF253530);
  static const Color darkText = Color(0xFFECF5F0);
  static const Color darkSub = Color(0xFF7A9E8E);

  // Light
  static const Color lightBg = Color(0xFFF0F9F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE4F3EB);
  static const Color lightBorder = Color(0xFFC3DECE);
  static const Color lightText = Color(0xFF0C1E16);
  static const Color lightSub = Color(0xFF4D7A63);

  static const List<Color> accentOptions = [
    emerald,
    forest,
    gold,
    sapphire,
    rose,
    violet,
    crimson,
    cyan,
  ];
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData dark(Color accent) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: AppColors.darkSurface,
      background: AppColors.darkBg,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
    useMaterial3: true,
  );

  static ThemeData light(Color accent) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.light(
      primary: accent,
      secondary: accent,
      surface: AppColors.lightSurface,
      background: AppColors.lightBg,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightBorder,
    useMaterial3: true,
  );
}

// ─── Helpers (theme-aware shortcuts) ─────────────────────────────────────────

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardBg => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textColor => isDark ? AppColors.darkText : AppColors.lightText;
  Color get subColor => isDark ? AppColors.darkSub : AppColors.lightSub;
}

// ─── Constants ────────────────────────────────────────────────────────────────

class AppConstants {
  static const String appName = 'Dhikr';
  static const String appVersion = '2.0.0';
  static const String developerName = 'Your Name';
  static const String appDescription =
      'A distraction-free dhikr counter to help you stay connected '
      'with daily remembrance of Allah.';

  static const List<Map<String, String>> predefinedDhikr = [
    {
      'title': 'Subhanallah',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'meaning': 'Glory be to Allah',
    },
    {
      'title': 'Alhamdulillah',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'meaning': 'All praise is due to Allah',
    },
    {
      'title': 'Allahu Akbar',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'meaning': 'Allah is the Greatest',
    },
    {
      'title': 'Swalath',
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'meaning': 'Blessings upon Prophet Muhammad ﷺ',
    },
    {
      'title': 'Astaghfirullah',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'meaning': 'I seek forgiveness from Allah',
    },
    {
      'title': 'La ilaha illallah',
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'meaning': 'There is no god but Allah',
    },
  ];

  static const List<int> quickTargets = [33, 66, 99, 100, 500, 1000];
}
