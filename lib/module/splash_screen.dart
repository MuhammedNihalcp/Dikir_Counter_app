import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/app_provider.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _revealCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _orbitAnim;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _orbitAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(_orbitCtrl);

    _logoFade = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeIn);
    _logoScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _revealCtrl, curve: Curves.elasticOut));

    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    Future.delayed(
      const Duration(milliseconds: 200),
      () => _revealCtrl.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 900),
      () => _textCtrl.forward(),
    );
    Future.delayed(const Duration(milliseconds: 3200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _revealCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.read<AppProvider>().accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF050E09),
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbitAnim,
              builder: (_, _) =>
                  CustomPaint(painter: _BgPainter(_orbitAnim.value, accent)),
            ),
          ),

          // Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _Logo(accent: accent),
                  ),
                ),
                const SizedBox(height: 36),
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: _AppTitle(accent: accent),
                  ),
                ),
              ],
            ),
          ),

          // Version at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Center(
                child: Text(
                  'Remember Allah in every breath',
                  style: GoogleFonts.amiri(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo widget ───────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final Color accent;
  const _Logo({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
          // Dotted orbit ring
          CustomPaint(
            size: const Size(130, 130),
            painter: _DotRingPainter(accent),
          ),
          // Inner circle
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          // Arabic ذ
          Text(
            'ذ',
            style: GoogleFonts.amiri(
              color: accent,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── App title widget ──────────────────────────────────────────────────────────

class _AppTitle extends StatelessWidget {
  final Color accent;
  const _AppTitle({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'DHIKR',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ذِكْر',
          style: GoogleFonts.amiri(
            color: accent,
            fontSize: 24,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, accent, Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'C O U N T E R',
          style: GoogleFonts.orbitron(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 10,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  final double angle;
  final Color accent;
  _BgPainter(this.angle, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p = Paint()..style = PaintingStyle.stroke;

    for (int i = 1; i <= 6; i++) {
      p
        ..color = accent.withValues(alpha: 0.025 * (7 - i).toDouble())
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset(cx, cy), 80.0 * i, p);
    }

    p
      ..strokeWidth = 0.3
      ..color = accent.withValues(alpha: 0.05);
    for (int i = 0; i < 12; i++) {
      final a = angle + (i * math.pi / 6);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(a) * size.width, cy + math.sin(a) * size.height),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.angle != angle;
}

class _DotRingPainter extends CustomPainter {
  final Color color;
  _DotRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final r = size.width / 2 - 5;
    final center = Offset(size.width / 2, size.height / 2);
    const dots = 36;

    for (int i = 0; i < dots; i++) {
      final a = (i / dots) * 2 * math.pi;
      p.color = color.withValues(alpha: i % 3 == 0 ? 0.8 : 0.3);
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        i % 6 == 0 ? 2.5 : 1.2,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_DotRingPainter old) => false;
}
