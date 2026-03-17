import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../provider/app_provider.dart';
import '../utils/app_theme.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with TickerProviderStateMixin {
  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _countBumpCtrl;

  late Animation<double> _pulseAnim;
  late Animation<double> _rippleAnim;
  late Animation<double> _bumpAnim;

  bool _rippleVisible = false;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _countBumpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rippleAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _bumpAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_countBumpCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _countBumpCtrl.dispose();
    super.dispose();
  }

  // ── Tap handler ──────────────────────────────────────────────────────────────

  Future<void> _onTap() async {
    final p = context.read<AppProvider>();
    if (p.activeSession == null || p.activeSession!.isCompleted) return;

    p.increment();
    _countBumpCtrl.forward(from: 0);

    // Haptic
    if (p.vibrationEnabled) {
      HapticFeedback.lightImpact();
      final has = await Vibration.hasVibrator();
      if (has) Vibration.vibrate(duration: 28, amplitude: 60);
    }

    // Ripple
    setState(() => _rippleVisible = true);
    _rippleCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _rippleVisible = false);
    });
  }

  // ── Pause ─────────────────────────────────────────────────────────────────

  void _pause() {
    final p = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PauseSheet(
        accent: p.accentColor,
        isDark: p.isDarkMode,
        onPause: () async {
          Navigator.pop(context);
          await p.pauseSession();
          if (mounted) Navigator.pop(context);
        },
        onDiscard: () {
          Navigator.pop(context);
          p.discardActiveSession();
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final p = context.read<AppProvider>();
    await p.saveSession();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅  Session saved to history',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: p.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final session = p.activeSession;
    final accent = p.accentColor;

    if (session == null) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: Text('No active session')),
      );
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Radial glow background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, _) => CustomPaint(
                  painter: _GlowPainter(accent, _pulseAnim.value),
                ),
              ),
            ),

            // Ripple
            if (_rippleVisible)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, _) => CustomPaint(
                    painter: _RipplePainter(accent, _rippleAnim.value),
                  ),
                ),
              ),

            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        _CircleBtn(
                          icon: Icons.arrow_back_ios_rounded,
                          accent: accent,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        if (!session.isCompleted)
                          _CircleBtn(
                            icon: Icons.pause_rounded,
                            accent: accent,
                            onTap: _pause,
                          ),
                      ],
                    ),
                  ),

                  // ── Dhikr info ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        if (session.arabic.isNotEmpty)
                          Text(
                            session.arabic,
                            style: GoogleFonts.amiri(
                              color: accent,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          session.title,
                          style: GoogleFonts.nunito(
                            color: context.textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (session.meaning.isNotEmpty)
                          Text(
                            session.meaning,
                            style: GoogleFonts.nunito(
                              color: context.subColor,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Big count ──
                  AnimatedBuilder(
                    animation: _bumpAnim,
                    builder: (_, child) =>
                        Transform.scale(scale: _bumpAnim.value, child: child),
                    child: Text(
                      session.count.toString(),
                      style: GoogleFonts.orbitron(
                        color: context.textColor,
                        fontSize: 100,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),

                  // ── Progress bar ──
                  if (session.hasTarget) ...[
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: session.progress,
                              backgroundColor: accent.withValues(alpha: 0.15),
                              color: accent,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${session.count} / ${session.targetCount}',
                            style: GoogleFonts.nunito(
                              color: context.subColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Completed badge ──
                  if (session.isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '🎉  Target Reached!',
                        style: GoogleFonts.nunito(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // ── Tap button ──
                  _TapBtn(
                    accent: accent,
                    isCompleted: session.isCompleted,
                    pulseAnim: _pulseAnim,
                    onTap: _onTap,
                  ),

                  const Spacer(),

                  // ── Bottom actions ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        // Reset
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.refresh_rounded,
                            label: 'Reset',
                            color: accent.withValues(alpha: 0.1),
                            textColor: accent,
                            borderColor: accent.withValues(alpha: 0.25),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  'Reset?',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                content: Text(
                                  'Count will be reset to 0.',
                                  style: GoogleFonts.nunito(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      p.resetCounter();
                                    },
                                    child: const Text('Reset'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Save
                        Expanded(
                          flex: 2,
                          child: _ActionBtn(
                            icon: Icons.check_circle_rounded,
                            label: 'Save Session',
                            color: accent,
                            textColor: Colors.white,
                            onTap: _save,
                            shadow: BoxShadow(
                              color: accent.withValues(alpha: 0.38),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TapBtn extends StatelessWidget {
  final Color accent;
  final bool isCompleted;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _TapBtn({
    required this.accent,
    required this.isCompleted,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, _) => GestureDetector(
        onTap: isCompleted ? null : onTap,
        child: Container(
          width: 186,
          height: 186,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28 * pulseAnim.value),
                blurRadius: 56,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isCompleted ? 0.35 : 0.22),
                  accent.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: isCompleted ? 0.3 : 0.55),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: accent, size: 60)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: accent, size: 42),
                        const SizedBox(height: 6),
                        Text(
                          'TAP',
                          style: GoogleFonts.orbitron(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const _CircleBtn({
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: context.textColor, size: 18),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, textColor;
  final Color? borderColor;
  final BoxShadow? shadow;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.borderColor,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Pause bottom sheet ───────────────────────────────────────────────────────

class _PauseSheet extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final VoidCallback onPause, onDiscard;

  const _PauseSheet({
    required this.accent,
    required this.isDark,
    required this.onPause,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkCard : Colors.white;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Pause Session?',
            style: GoogleFonts.nunito(
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Progress is saved. Resume anytime from History.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: isDark ? AppColors.darkSub : AppColors.lightSub,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SheetBtn(
                    label: '🗑  Discard',
                    bg: Colors.red.withValues(alpha: 0.1),
                    fg: Colors.redAccent,
                    onTap: onDiscard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetBtn(
                    label: '⏸  Pause & Save',
                    bg: accent,
                    fg: Colors.white,
                    onTap: onPause,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final VoidCallback onTap;
  const _SheetBtn({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _GlowPainter extends CustomPainter {
  final Color color;
  final double intensity;
  _GlowPainter(this.color, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                color.withValues(alpha: 0.13 * intensity),
                color.withValues(alpha: 0.04 * intensity),
                Colors.transparent,
              ],
              stops: const [0, 0.45, 1],
            ).createShader(
              Rect.fromCenter(
                center: Offset(size.width / 2, size.height * 0.54),
                width: size.width * 1.3,
                height: size.height * 1.3,
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.intensity != intensity;
}

class _RipplePainter extends CustomPainter {
  final Color color;
  final double progress;
  _RipplePainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.54),
      math.max(size.width, size.height) * progress,
      Paint()
        ..color = color.withValues(alpha: (1 - progress) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}
