//
// All business logic lives here. Hive I/O is delegated to HiveService.
// The provider is injected at the root so every screen can read/write state.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/hive_service.dart';
import '../model/dikir_session.dart';

class AppProvider extends ChangeNotifier {
  // ── In-memory caches (Hive is the source of truth) ──────────────────────────

  late AppSettings _settings;
  late UserProfile _profile;

  /// The session currently open in the counter screen (not yet persisted).
  DhikrSession? _activeSession;

  // ── Getters ──────────────────────────────────────────────────────────────────

  AppSettings get settings => _settings;
  UserProfile get profile => _profile;
  DhikrSession? get activeSession => _activeSession;

  bool get isDarkMode => _settings.isDarkMode;
  Color get accentColor => Color(_settings.accentColorValue);
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get soundEnabled => _settings.soundEnabled;

  /// History = all persisted sessions (paused + completed), newest first.
  List<DhikrSession> get history => HiveService.getHistory();

  // ── Constructor ──────────────────────────────────────────────────────────────

  AppProvider() {
    _settings = HiveService.getSettings();
    _profile = HiveService.getProfile();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Counter
  // ════════════════════════════════════════════════════════════════════════════

  /// Creates a brand-new in-memory session (not saved to Hive yet).
  void startNewSession({
    required String title,
    required String arabic,
    required String meaning,
    int targetCount = 0,
  }) {
    final now = DateTime.now();
    _activeSession = DhikrSession(
      id: const Uuid().v4(),
      title: title,
      arabic: arabic,
      meaning: meaning,
      targetCount: targetCount,
      createdAt: now,
      updatedAt: now,
      status: SessionStatus.active,
    );
    notifyListeners();
  }

  /// Load a paused session from Hive back into the counter screen.
  Future<void> resumeSession(DhikrSession session) async {
    // Remove from Hive while it's active again
    await HiveService.deleteSession(session.id);
    _activeSession = session.copyWith(
      status: SessionStatus.active,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Increment the in-memory counter by 1.
  void increment() {
    final s = _activeSession;
    if (s == null || s.isCompleted) return;
    s.count++;
    s.updatedAt = DateTime.now();
    // Auto-complete when target reached
    if (s.hasTarget && s.count >= s.targetCount) {
      _activeSession = s.copyWith(status: SessionStatus.completed);
    }
    notifyListeners();
  }

  /// Reset in-memory counter to 0.
  void resetCounter() {
    final s = _activeSession;
    if (s == null) return;
    s.count = 0;
    s.updatedAt = DateTime.now();
    // Restore to active if it was auto-completed
    if (s.isCompleted) {
      _activeSession = s.copyWith(status: SessionStatus.active);
    }
    notifyListeners();
  }

  /// Pause → persist to Hive with status = paused, clear active session.
  Future<void> pauseSession() async {
    final s = _activeSession;
    if (s == null) return;
    final paused = s.copyWith(
      status: SessionStatus.paused,
      updatedAt: DateTime.now(),
    );
    await HiveService.saveSession(paused);
    _activeSession = null;
    notifyListeners();
  }

  /// Save → persist to Hive with status = completed, update profile totals.
  Future<void> saveSession() async {
    final s = _activeSession;
    if (s == null) return;
    final completed = s.copyWith(
      status: SessionStatus.completed,
      updatedAt: DateTime.now(),
    );
    await HiveService.saveSession(completed);

    // Update profile aggregates
    _profile.totalCount += completed.count;
    _profile.totalSessions += 1;
    await HiveService.saveProfile(_profile);

    _activeSession = null;
    notifyListeners();
  }

  /// Discard the active session without saving anything.
  void discardActiveSession() {
    _activeSession = null;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // History
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> deleteSession(String id) async {
    await HiveService.deleteSession(id);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await HiveService.clearAllSessions();
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Settings
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> toggleDarkMode() async {
    _settings.isDarkMode = !_settings.isDarkMode;
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _settings.accentColorValue = color.value;
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _settings.vibrationEnabled = !_settings.vibrationEnabled;
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _settings.soundEnabled = !_settings.soundEnabled;
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Profile
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> updateProfileName(String name) async {
    _profile.name = name.trim().isEmpty ? 'Muslim' : name.trim();
    await HiveService.saveProfile(_profile);
    notifyListeners();
  }
}
