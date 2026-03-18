//
// Single entry-point for all Hive operations.
// Three boxes:
//   • sessionsBox  – stores List<DhikrSession>  (key = session.id)
//   • profileBox   – stores one UserProfile     (key = 'profile')
//   • settingsBox  – stores one AppSettings     (key = 'settings')

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/dikir_session.dart';

class HiveService {
  // Box names
  static const String _sessionsBoxName = 'sessions';
  static const String _profileBoxName = 'profile';
  static const String _settingsBoxName = 'settings';
  static const String _newDhikrBoxName = 'newdhikr';

  // Profile / settings keys
  static const String _profileKey = 'profile';
  static const String _settingsKey = 'settings';

  // ── Initialise ──────────────────────────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (order doesn't matter, typeIds must be unique)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DhikrSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    // Open boxes
    await Hive.openBox<DhikrSession>(_sessionsBoxName);
    await Hive.openBox<UserProfile>(_profileBoxName);
    await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  // ── Box accessors ───────────────────────────────────────────────────────────

  static Box<DhikrSession> get _sessions =>
      Hive.box<DhikrSession>(_sessionsBoxName);

  static Box<UserProfile> get _profileBox =>
      Hive.box<UserProfile>(_profileBoxName);

  static Box<AppSettings> get _settingsBox =>
      Hive.box<AppSettings>(_settingsBoxName);

  // ── Sessions CRUD ───────────────────────────────────────────────────────────

  /// Returns all sessions sorted newest-first.
  static List<DhikrSession> getAllSessions() {
    final list = _sessions.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Returns only paused + completed sessions.
  static List<DhikrSession> getHistory() {
    final list = _sessions.values
        // .where((s) => s.status != SessionStatus.active)
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Save or update a session (key = session.id).
  static Future<void> saveSession(DhikrSession session) async {
    await _sessions.put(session.id, session);
  }

  /// Delete a single session by id.
  static Future<void> deleteSession(String id) async {
    await _sessions.delete(id);
  }

  /// Wipe all sessions.
  static Future<void> clearAllSessions() async {
    await _sessions.clear();
  }

  // ── Profile ─────────────────────────────────────────────────────────────────

  static UserProfile getProfile() {
    return _profileBox.get(_profileKey) ?? UserProfile();
  }

  static Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put(_profileKey, profile);
  }

  // ── Settings ─────────────────────────────────────────────────────────────────

  static AppSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }

  // ── Listenable helpers (for ValueListenableBuilder) ─────────────────────────

  static ValueListenable<Box<DhikrSession>> get sessionsListenable =>
      _sessions.listenable();

  static ValueListenable<Box<UserProfile>> get profileListenable =>
      _profileBox.listenable();

  static ValueListenable<Box<AppSettings>> get settingsListenable =>
      _settingsBox.listenable();
}
