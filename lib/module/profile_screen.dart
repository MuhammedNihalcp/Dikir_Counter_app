import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../db/hive_service.dart';
import '../model/dikir_session.dart';
import '../provider/app_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<AppProvider>().profile.name,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final p = context.read<AppProvider>();
    p.updateProfileName(_nameCtrl.text);
    setState(() => _editing = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: p.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final accent = p.accentColor;

    // Height of the pinned Bismillah footer so scroll content doesn't hide
    // behind it
    const double bismillahHeight = 72;

    return Scaffold(
      backgroundColor: context.bg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable body ────────────────────────────────────────────
            Column(
              children: [
                // Header — never scrolls
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: context.textColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Profile',
                        style: GoogleFonts.nunito(
                          color: context.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      // Push content above the pinned Bismillah footer
                      // and also above the keyboard when it opens
                      bottom:
                          bismillahHeight +
                          MediaQuery.of(context).viewInsets.bottom +
                          16,
                    ),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // ── Avatar ─────────────────────────────────────────
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [accent, accent.withValues(alpha: 0.5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.38),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ValueListenableBuilder<Box<UserProfile>>(
                              valueListenable: HiveService.profileListenable,
                              builder: (_, box, __) {
                                final name = box.get('profile')?.name ?? 'M';
                                return Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Stat cards ─────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ValueListenableBuilder<Box<UserProfile>>(
                            valueListenable: HiveService.profileListenable,
                            builder: (_, box, __) {
                              final profile =
                                  box.get('profile') ?? UserProfile();
                              return Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.spa_rounded,
                                      label: 'Total Dhikr',
                                      value: profile.totalCount.toString(),
                                      accent: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.history_rounded,
                                      label: 'Sessions',
                                      value: profile.totalSessions.toString(),
                                      accent: accent,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Name editor ────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: context.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'YOUR NAME',
                                  style: GoogleFonts.nunito(
                                    color: context.subColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _editing
                                          ? TextField(
                                              controller: _nameCtrl,
                                              autofocus: true,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onSubmitted: (_) => _save(),
                                              style: GoogleFonts.nunito(
                                                color: context.textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Enter your name',
                                                hintStyle: GoogleFonts.nunito(
                                                  color: context.subColor,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            )
                                          : Text(
                                              p.profile.name,
                                              style: GoogleFonts.nunito(
                                                color: context.textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                    GestureDetector(
                                      onTap: _editing
                                          ? _save
                                          : () =>
                                                setState(() => _editing = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 160,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _editing
                                              ? accent
                                              : accent.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          _editing ? 'Save' : 'Edit',
                                          style: GoogleFonts.nunito(
                                            color: _editing
                                                ? Colors.white
                                                : accent,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Pinned Bismillah footer ────────────────────────────────────
            // Uses Align so it sticks to the very bottom of the Stack,
            // slides up with the keyboard via AnimatedPadding.
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              // Lift the footer above the keyboard when it's open
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 8
                    : 0,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: bismillahHeight,
                  // Frosted-glass effect: a gradient fade from transparent
                  // to the background colour hides content scrolling under it
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.bg.withValues(alpha: 0.0),
                        context.bg.withValues(alpha: 0.95),
                        context.bg,
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          color: accent.withValues(alpha: 0.7),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In the name of Allah, the Most Gracious, the Most Merciful',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: context.subColor,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: context.textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(color: context.subColor, fontSize: 12),
        ),
      ],
    ),
  );
}
