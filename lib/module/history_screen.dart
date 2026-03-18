//
// Uses ValueListenableBuilder on the Hive sessions box so the list
// rebuilds automatically whenever any session is added / updated / deleted.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../db/hive_service.dart';
import '../model/dikir_session.dart';
import '../provider/app_provider.dart';
import '../utils/app_theme.dart';
import 'counter_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // ── helpers ──────────────────────────────────────────────────────────────────
  void _resume(BuildContext ctx, AppProvider p, DhikrSession s) async {
    Future<void> go() async {
      await p.resumeSession(s);
      if (ctx.mounted) _pushCounter(ctx);
    }

    if (p.activeSession != null) {
      showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text(
            'Active Session',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Discard current session and resume this one?',
            style: GoogleFonts.nunito(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                p.discardActiveSession();
                await go();
              },
              child: const Text('Resume'),
            ),
          ],
        ),
      );
    } else {
      await go();
    }
  }

  void _pushCounter(BuildContext ctx) => Navigator.push(
    ctx,
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

  void _delete(BuildContext ctx, AppProvider p, String id) => showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(
        'Delete?',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Remove this session from history?',
        style: GoogleFonts.nunito(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            p.deleteSession(id);
          },
          child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
        ),
      ],
    ),
  );

  void _clearAll(BuildContext ctx, AppProvider p) => showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(
        'Clear All?',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'This will permanently delete all history.',
        style: GoogleFonts.nunito(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            p.clearHistory();
          },
          child: Text(
            'Clear All',
            style: TextStyle(color: Colors.red.shade400),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: GoogleFonts.nunito(
                          color: context.textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  // Clear All – only shown when there IS history
                  ValueListenableBuilder<Box<DhikrSession>>(
                    valueListenable: HiveService.sessionsListenable,
                    builder: (_, box, _) {
                      final hasHistory = box.values.any(
                        (s) => s.status != SessionStatus.active,
                      );
                      return hasHistory
                          ? GestureDetector(
                              onTap: () => _clearAll(context, p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  'Clear All',
                                  style: GoogleFonts.nunito(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── List (reactive to Hive) ──
            Expanded(
              child: ValueListenableBuilder<Box<DhikrSession>>(
                valueListenable: HiveService.sessionsListenable,
                builder: (_, box, _) {
                  final history =
                      box.values
                          // .where((s) => s.status != SessionStatus.active)
                          .toList()
                        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                  if (history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📿', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'No history yet',
                            style: GoogleFonts.nunito(
                              color: context.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Complete or pause a session\nto see it here',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: context.subColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final s = history[i];
                      return _HistoryCard(
                        session: s,
                        accent: p.accentColor,
                        onResume: s.isPaused ? () => _resume(ctx, p, s) : null,
                        onDelete: () => _delete(ctx, p, s.id),
                        // onTab: s.isSaved ? () => _resume(ctx, p, s) : null,
                        onCountinue: s.isSaved
                            ? () => _resume(ctx, p, s)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final DhikrSession session;
  final Color accent;
  final VoidCallback? onResume;
  final VoidCallback? onCountinue;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.session,
    required this.accent,
    this.onResume,
    required this.onDelete,
    this.onCountinue,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = session.isPaused;
    final isSaved = session.isSaved;
    final statusColor = isPaused
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);
    final statusLabel = isPaused
        ? '⏸  Paused'
        : isSaved
        ? '💾 Saved'
        : '✅  Completed';
    final formattedDate = DateFormat(
      'MMM d, y  •  hh:mm a',
    ).format(session.updatedAt);

    return
    // Dismissible(
    //   key: Key(session.id),
    //   direction: DismissDirection.endToStart,
    //   background: Container(
    //     alignment: Alignment.centerRight,
    //     padding: const EdgeInsets.only(right: 24),
    //     decoration: BoxDecoration(
    //       color: Colors.red.withValues(alpha: 0.12),
    //       borderRadius: BorderRadius.circular(22),
    //     ),
    //     child: const Icon(
    //       Icons.delete_rounded,
    //       color: Colors.redAccent,
    //       size: 22,
    //     ),
    //   ),
    //   // onUpdate: (_) => onDelete(),
    //   onDismissed: (_) => onDelete(),
    //   child:
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (session.arabic.isNotEmpty)
                      Text(
                        session.arabic,
                        style: GoogleFonts.amiri(
                          color: accent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        // textDirection: TextDirection.RTL,
                      ),
                    Text(
                      session.title,
                      style: GoogleFonts.nunito(
                        color: context.textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formattedDate,
                      style: GoogleFonts.nunito(
                        color: context.subColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    session.count.toString(),
                    style: GoogleFonts.orbitron(
                      color: accent,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'counts',
                    style: GoogleFonts.nunito(
                      color: context.subColor,
                      fontSize: 11,
                    ),
                  ),
                  if (session.hasTarget)
                    Text(
                      '/ ${session.targetCount}',
                      style: GoogleFonts.nunito(
                        color: context.subColor,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Progress bar (if has target) ──
          if (session.hasTarget) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: session.progress,
                backgroundColor: accent.withValues(alpha: 0.12),
                color: accent,
                minHeight: 4,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Footer ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.nunito(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              // Delete icon
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ),
              // Resume button (only for paused)
              if (onResume != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onResume,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resume',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Countinue button (only for saved)
              if (onCountinue != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCountinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Countinue',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      // ),
    );
  }
}
