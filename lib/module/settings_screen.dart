import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/app_provider.dart';
import '../utils/app_theme.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final accent = p.accentColor;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Title ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                child: Text(
                  'Settings',
                  style: GoogleFonts.nunito(
                    color: context.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // ── Profile card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: context.border),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [accent, accent.withValues(alpha: 0.55)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.profile.name.isNotEmpty
                                  ? p.profile.name[0].toUpperCase()
                                  : 'M',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.profile.name,
                                style: GoogleFonts.nunito(
                                  color: context.textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${p.profile.totalCount} dhikr · ${p.profile.totalSessions} sessions',
                                style: GoogleFonts.nunito(
                                  color: context.subColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.subColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── Appearance ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('APPEARANCE'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: context.border),
                      ),
                      child: Column(
                        children: [
                          // Dark mode
                          _Tile(
                            icon: p.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            label: 'Dark Mode',
                            accent: accent,
                            trailing: Switch(
                              value: p.isDarkMode,
                              onChanged: (_) => p.toggleDarkMode(),
                              activeThumbColor: accent,
                            ),
                          ),
                          Divider(height: 1, color: context.border),
                          // Accent colour label
                          _Tile(
                            icon: Icons.palette_rounded,
                            label: 'Accent Color',
                            accent: accent,
                          ),
                          // Colour swatches
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: AppColors.accentOptions.map((c) {
                                final sel = c.value == accent.value;
                                return GestureDetector(
                                  onTap: () => p.setAccentColor(c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: sel
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            )
                                          : null,
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                color: c.withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: sel
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── Feedback ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('FEEDBACK'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: context.border),
                      ),
                      child: Column(
                        children: [
                          _Tile(
                            icon: Icons.vibration_rounded,
                            label: 'Vibration',
                            subtitle: 'Haptic feedback on tap',
                            accent: accent,
                            trailing: Switch(
                              value: p.vibrationEnabled,
                              onChanged: (_) => p.toggleVibration(),
                              activeThumbColor: accent,
                            ),
                          ),
                          Divider(height: 1, color: context.border),
                          _Tile(
                            icon: Icons.volume_up_rounded,
                            label: 'Sound',
                            subtitle: 'Audio click on tap',
                            accent: accent,
                            trailing: Switch(
                              value: p.soundEnabled,
                              onChanged: (_) => p.toggleSound(),
                              activeThumbColor: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── About ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('ABOUT'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: context.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accent,
                                      accent.withValues(alpha: 0.55),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'ذ',
                                    style: GoogleFonts.amiri(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.appName,
                                    style: GoogleFonts.orbitron(
                                      color: context.textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    'v${AppConstants.appVersion}',
                                    style: GoogleFonts.nunito(
                                      color: context.subColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            AppConstants.appDescription,
                            style: GoogleFonts.nunito(
                              color: context.subColor,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'By ',
                                style: GoogleFonts.nunito(
                                  color: context.subColor,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                AppConstants.developerName,
                                style: GoogleFonts.nunito(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 6),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.storage_rounded,
                          //       color: context.subColor,
                          //       size: 13,
                          //     ),
                          //     const SizedBox(width: 5),
                          //     Text(
                          //       'Powered by Hive local database',
                          //       style: GoogleFonts.nunito(
                          //         color: context.subColor,
                          //         fontSize: 11,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Utility widgets ───────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: GoogleFonts.nunito(
        color: context.subColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.7,
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color accent;
  final Widget? trailing;

  const _Tile({
    required this.icon,
    required this.label,
    required this.accent,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: context.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.nunito(
                    color: context.subColor,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
