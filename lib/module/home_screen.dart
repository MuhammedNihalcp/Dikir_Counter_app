import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/app_provider.dart';
import '../utils/app_theme.dart';
import 'counter_screen.dart';
import 'create_counter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Navigate to counter ──────────────────────────────────────────────────────

  void _pick(
    BuildContext context,
    AppProvider p,
    String title,
    String arabic,
    String meaning,
  ) {
    void go() {
      p.startNewSession(title: title, arabic: arabic, meaning: meaning);
      _pushCounter(context);
    }

    if (p.activeSession != null) {
      showDialog(
        context: context,
        builder: (_) => _DiscardDialog(
          accent: p.accentColor,
          isDark: p.isDarkMode,
          onConfirm: () {
            Navigator.pop(context);
            p.discardActiveSession();
            go();
          },
        ),
      );
    } else {
      go();
    }
  }

  void _pushCounter(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CounterScreen(),
        transitionsBuilder: (_, a, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final accent = p.accentColor;

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu Alaikum',
                              style: GoogleFonts.nunito(
                                color: context.subColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              p.profile.name,
                              style: GoogleFonts.nunito(
                                color: context.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        _TotalBadge(
                          count: p.profile.totalCount,
                          accent: accent,
                        ),
                      ],
                    ),

                    // Active session banner
                    if (p.activeSession != null) ...[
                      const SizedBox(height: 18),
                      _ActiveBanner(
                        session: p.activeSession!,
                        accent: accent,
                        isDark: p.isDarkMode,
                        onResume: () => _pushCounter(context),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // ── Section label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'CHOOSE DHIKR',
                style: GoogleFonts.nunito(
                  color: context.subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),

          // ── Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final d = AppConstants.predefinedDhikr[i];
                return _DhikrTile(
                  title: d['title']!,
                  arabic: d['arabic']!,
                  meaning: d['meaning']!,
                  accent: accent,
                  onTap: () => _pick(
                    context,
                    p,
                    d['title']!,
                    d['arabic']!,
                    d['meaning']!,
                  ),
                );
              }, childCount: AppConstants.predefinedDhikr.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
            ),
          ),

          // ── Custom Dhikr button ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _CustomDhikrBtn(
                accent: accent,
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateDhikrScreen(),
                    ),
                  );
                  if (result != null && context.mounted) {
                    p.startNewSession(
                      title: result['title'] as String,
                      arabic: result['arabic'] as String,
                      meaning: result['meaning'] as String,
                      targetCount: result['targetCount'] as int,
                    );
                    _pushCounter(context);
                  }
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _TotalBadge extends StatelessWidget {
  final int count;
  final Color accent;
  const _TotalBadge({required this.count, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: accent.withValues(alpha: 0.25)),
    ),
    child: Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.orbitron(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'TOTAL',
          style: GoogleFonts.nunito(
            color: accent.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ActiveBanner extends StatelessWidget {
  final dynamic session;
  final Color accent;
  final bool isDark;
  final VoidCallback onResume;

  const _ActiveBanner({
    required this.session,
    required this.accent,
    required this.isDark,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active: ${session.title}',
                  style: GoogleFonts.nunito(
                    color: context.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${session.count} counts',
                  style: GoogleFonts.nunito(color: accent, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onResume,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Resume',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrTile extends StatefulWidget {
  final String title, arabic, meaning;
  final Color accent;
  final VoidCallback onTap;

  const _DhikrTile({
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_DhikrTile> createState() => _DhikrTileState();
}

class _DhikrTileState extends State<_DhikrTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accent.withValues(alpha: 0.12)
                : context.cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _pressed
                  ? widget.accent.withValues(alpha: 0.4)
                  : context.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.arabic,
                style: GoogleFonts.amiri(
                  color: widget.accent,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.nunito(
                      color: context.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.meaning,
                    style: GoogleFonts.nunito(
                      color: context.subColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDhikrBtn extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  const _CustomDhikrBtn({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.07),
            accent.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline_rounded, color: accent, size: 22),
          const SizedBox(width: 10),
          Text(
            'Create Custom Dhikr',
            style: GoogleFonts.nunito(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DiscardDialog extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final VoidCallback onConfirm;
  const _DiscardDialog({
    required this.accent,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: isDark ? AppColors.darkCard : Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(
      'Active Session',
      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
    ),
    content: Text(
      'Discard the current session and start a new one?',
      style: GoogleFonts.nunito(fontSize: 14),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: onConfirm,
        child: Text('Discard', style: TextStyle(color: Colors.red.shade400)),
      ),
    ],
  );
}
