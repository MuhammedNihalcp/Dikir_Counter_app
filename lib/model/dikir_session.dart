import 'package:hive/hive.dart';

part 'dikir_session.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
enum SessionStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  paused,

  @HiveField(2)
  completed,

  @HiveField(3)
  saved,
}

// ─── DhikrSession ────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class DhikrSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String arabic;

  @HiveField(3)
  String meaning;

  @HiveField(4)
  int count;

  @HiveField(5)
  int targetCount; // 0 = unlimited

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  SessionStatus status;

  DhikrSession({
    required this.id,
    required this.title,
    this.arabic = '',
    this.meaning = '',
    this.count = 0,
    this.targetCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.status = SessionStatus.active,
  });

  // Convenience getters
  bool get isCompleted => status == SessionStatus.completed;
  bool get isPaused => status == SessionStatus.paused;
  bool get isActive => status == SessionStatus.active;
  bool get isSaved => status == SessionStatus.saved;
  bool get hasTarget => targetCount > 0;
  double get progress =>
      hasTarget ? (count / targetCount).clamp(0.0, 1.0) : 0.0;

  DhikrSession copyWith({
    String? id,
    String? title,
    String? arabic,
    String? meaning,
    int? count,
    int? targetCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    SessionStatus? status,
  }) => DhikrSession(
    id: id ?? this.id,
    title: title ?? this.title,
    arabic: arabic ?? this.arabic,
    meaning: meaning ?? this.meaning,
    count: count ?? this.count,
    targetCount: targetCount ?? this.targetCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    status: status ?? this.status,
  );
}

// ─── UserProfile ──────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int totalCount;

  @HiveField(2)
  int totalSessions;

  UserProfile({
    this.name = 'Muslim',
    this.totalCount = 0,
    this.totalSessions = 0,
  });
}

// ─── AppSettings ──────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  int accentColorValue;

  @HiveField(2)
  bool vibrationEnabled;

  @HiveField(3)
  bool soundEnabled;

  AppSettings({
    this.isDarkMode = true,
    this.accentColorValue = 0xFF10B981, // emerald
    this.vibrationEnabled = true,
    this.soundEnabled = false,
  });
}
