import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/app_provider.dart';
import '../utils/app_theme.dart';

class CreateDhikrScreen extends StatefulWidget {
  const CreateDhikrScreen({super.key});
  @override
  State<CreateDhikrScreen> createState() => _CreateDhikrScreenState();
}

class _CreateDhikrScreenState extends State<CreateDhikrScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  bool _hasTarget = false;

  late AnimationController _enterCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _meaningCtrl.dispose();
    _targetCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    Navigator.pop(context, {
      'title': _titleCtrl.text.trim(),
      'arabic': _arabicCtrl.text.trim(),
      'meaning': _meaningCtrl.text.trim(),
      'targetCount': _hasTarget
          ? (int.tryParse(_targetCtrl.text.trim()) ?? 0)
          : 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppProvider>().accentColor;

    return Scaffold(
      backgroundColor: context.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                            Icons.close_rounded,
                            color: context.textColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Custom Dhikr',
                        style: GoogleFonts.nunito(
                          color: context.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Field(
                          label: 'Dhikr Name *',
                          hint: 'e.g. La Hawla Wala Quwwata',
                          ctrl: _titleCtrl,
                          accent: accent,
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: 'Arabic Text',
                          hint: 'لَا حَوْلَ وَلَا قُوَّةَ',
                          ctrl: _arabicCtrl,
                          accent: accent,
                          isArabic: true,
                        ),
                        const SizedBox(height: 16),
                        _Field(
                          label: 'Meaning',
                          hint: 'There is no power except with Allah',
                          ctrl: _meaningCtrl,
                          accent: accent,
                        ),
                        const SizedBox(height: 22),

                        // Target toggle card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Set Target Count',
                                        style: GoogleFonts.nunito(
                                          color: context.textColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Auto-complete when reached',
                                        style: GoogleFonts.nunito(
                                          color: context.subColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _hasTarget,
                                    onChanged: (v) =>
                                        setState(() => _hasTarget = v),
                                    activeThumbColor: accent,
                                  ),
                                ],
                              ),
                              if (_hasTarget) ...[
                                const SizedBox(height: 12),
                                _Field(
                                  label: 'Target Number',
                                  hint: 'e.g. 33, 100',
                                  ctrl: _targetCtrl,
                                  accent: accent,
                                  inputType: TextInputType.number,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Quick targets
                        Text(
                          'QUICK TARGETS',
                          style: GoogleFonts.nunito(
                            color: context.subColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: AppConstants.quickTargets.map((n) {
                            final selected =
                                _hasTarget && _targetCtrl.text == '$n';
                            return GestureDetector(
                              onTap: () => setState(() {
                                _hasTarget = true;
                                _targetCtrl.text = '$n';
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? accent
                                      : accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? accent
                                        : accent.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: Text(
                                  '$n',
                                  style: GoogleFonts.orbitron(
                                    color: selected ? Colors.white : accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CTA ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.38),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Start Counting',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable field widget ─────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final Color accent;
  final bool isArabic;
  final TextInputType inputType;

  const _Field({
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.accent,
    this.isArabic = false,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.nunito(
          color: context.subColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: inputType,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: isArabic
              ? GoogleFonts.amiri(color: context.textColor, fontSize: 18)
              : GoogleFonts.nunito(color: context.textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(
              color: context.subColor.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    ],
  );
}
