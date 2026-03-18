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
  static const String appVersion = '1.0.0';
  static const String developerName = 'Muhammed Nihal CP';
  static const String appDescription =
      'A distraction-free dhikr counter to help you stay connected '
      'with daily remembrance of Allah.';

  static const List<Map<String, String>> predefinedDhikr = [
    // ── The Core Tasbih (post-prayer 33×33×34) ──────────────────────────────
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

    // ── Salawat ──────────────────────────────────────────────────────────────
    {
      'title': 'Swalath',
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'meaning': 'Blessings upon Prophet Muhammad ﷺ',
    },
    {
      'title': 'Salawat Ibrahimiyyah',
      'arabic':
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ',
      'meaning':
          'O Allah, send blessings upon Muhammad and the family of Muhammad as You sent blessings upon Ibrahim',
    },

    // ── Istighfar ────────────────────────────────────────────────────────────
    {
      'title': 'Astaghfirullah',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'meaning': 'I seek forgiveness from Allah',
    },
    {
      'title': 'Astaghfirullah al-Azeem',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
      'meaning': 'I seek forgiveness from Allah, the Most Great',
    },
    {
      'title': 'Sayyid al-Istighfar',
      'arabic':
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ',
      'meaning':
          'O Allah, You are my Lord. There is no god but You. You created me and I am Your servant.',
    },

    // ── Tahlil / Shahada ─────────────────────────────────────────────────────
    {
      'title': 'La ilaha illallah',
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'meaning': 'There is no god but Allah',
    },
    {
      'title': 'La ilaha illallah Wahdah',
      'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'meaning': 'There is no god but Allah alone, with no partner',
    },
    {
      'title': 'La ilaha illallah (Full)',
      'arabic':
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'meaning':
          'There is no god but Allah alone. To Him belongs the dominion and all praise, and He is over all things Omnipotent',
    },

    // ── Hawqala & Basmala ────────────────────────────────────────────────────
    {
      'title': 'La Hawla Wala Quwwata',
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'meaning': 'There is no power and no strength except with Allah',
    },
    {
      'title': 'Bismillah',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'meaning': 'In the name of Allah, the Most Gracious, the Most Merciful',
    },
    {
      'title': 'Bismillah (Short)',
      'arabic': 'بِسْمِ اللَّهِ',
      'meaning': 'In the name of Allah',
    },

    // ── Combined Tasbih ──────────────────────────────────────────────────────
    {
      'title': 'Subhanallahi wa bihamdihi',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'meaning': 'Glory be to Allah and His is the praise',
    },
    {
      'title': 'Subhanallahi al-Azeem',
      'arabic': 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'meaning': 'Glory be to Allah, the Most Great',
    },
    {
      'title': 'Subhanallahi wa bihamdihi al-Azeem',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'meaning':
          'Glory and praise be to Allah; Glory be to Allah, the Most Great',
    },

    // ── Dua & Tawakkul ───────────────────────────────────────────────────────
    {
      'title': 'HasbunAllah',
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'meaning':
          'Allah is sufficient for us and He is the best Disposer of affairs',
    },
    {
      'title': 'HasbAllah',
      'arabic': 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
      'meaning':
          'Allah is sufficient for me. There is no god but He. In Him I put my trust.',
    },
    {
      'title': 'Tawakkaltu Alallah',
      'arabic': 'تَوَكَّلْتُ عَلَى اللَّهِ',
      'meaning': 'I put my trust in Allah',
    },

    // ── Gratitude ────────────────────────────────────────────────────────────
    {
      'title': 'Alhamdulillahi Rabbil Alameen',
      'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'meaning': 'All praise is due to Allah, Lord of all the worlds',
    },
    {
      'title': 'Alhamdulillahi Ala Kulli Hal',
      'arabic': 'الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ',
      'meaning': 'All praise is due to Allah in every circumstance',
    },
    {
      'title': 'Shukran Lillah',
      'arabic': 'شُكْرًا لِلَّهِ',
      'meaning': 'Thanks be to Allah',
    },

    // ── Morning & Evening Adhkar ─────────────────────────────────────────────
    {
      'title': 'Sabahul Khair Dhikr',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'meaning':
          'We have reached the morning and the dominion belongs to Allah',
    },
    {
      'title': 'Masa\'ul Khair Dhikr',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'meaning':
          'We have reached the evening and the dominion belongs to Allah',
    },
    {
      'title': 'Ayatul Kursi',
      'arabic': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'meaning':
          'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence',
    },

    // ── Protection ───────────────────────────────────────────────────────────
    {
      'title': 'A\'udhu Billah',
      'arabic': 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'meaning': 'I seek refuge in Allah from the accursed Satan',
    },
    {
      'title': 'A\'udhu Billahi min al-Hamm',
      'arabic': 'أَعُوذُ بِاللَّهِ مِنَ الْهَمِّ وَالْحَزَنِ',
      'meaning': 'I seek refuge in Allah from worry and grief',
    },

    // ── Inna Lillah ──────────────────────────────────────────────────────────
    {
      'title': 'Inna Lillahi',
      'arabic': 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
      'meaning': 'Indeed, to Allah we belong and to Him we shall return',
    },

    // ── Allahu Allahu ────────────────────────────────────────────────────────
    {
      'title': 'Allah Allah',
      'arabic': 'اللَّهُ اللَّهُ',
      'meaning': 'Allah, Allah (repetition of the Greatest Name)',
    },
    {'title': 'Ya Allah', 'arabic': 'يَا اللَّهُ', 'meaning': 'O Allah'},
    {
      'title': 'Ya Rahman',
      'arabic': 'يَا رَحْمَٰنُ',
      'meaning': 'O Most Gracious',
    },
    {
      'title': 'Ya Rahim',
      'arabic': 'يَا رَحِيمُ',
      'meaning': 'O Most Merciful',
    },
    {
      'title': 'Ya Hayyu Ya Qayyum',
      'arabic': 'يَا حَيُّ يَا قَيُّومُ',
      'meaning': 'O Ever-Living, O Eternal Sustainer',
    },
    {
      'title': 'Ya Ghaffar',
      'arabic': 'يَا غَفَّارُ اغْفِرْ لِي',
      'meaning': 'O Most Forgiving, forgive me',
    },

    // ── Surah Ikhlas ─────────────────────────────────────────────────────────
    {
      'title': 'Qul Huwallahu Ahad',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'meaning': 'Say: He is Allah, the One',
    },

    // ── Special Duas ─────────────────────────────────────────────────────────
    {
      'title': 'Rabbana Atina',
      'arabic':
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'meaning':
          'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire',
    },
    {
      'title': 'Rabbighfirli',
      'arabic':
          'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
      'meaning':
          'My Lord, forgive me and accept my repentance. Indeed, You are the Accepting of repentance, the Merciful',
    },
    {
      'title': 'Allahumma Aamini',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ',
      'meaning': 'O Allah, I ask You for well-being',
    },
    {
      'title': 'Allahumma Ahyina',
      'arabic': 'اللَّهُمَّ أَحْيِنَا بِالْإِيمَانِ',
      'meaning': 'O Allah, let us live with faith',
    },
  ];

  static const List<int> quickTargets = [33, 66, 99, 100, 500, 1000];
}
