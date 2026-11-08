import 'dart:convert';

// Represents user progression, XP points, and overall streaks.
class UserStats {
  const UserStats({
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 500,
    this.totalStreak = 0,
  });

  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int totalStreak;

  double get progress => (currentXp / xpToNextLevel).clamp(0.0, 1.0);

  UserStats copyWith({
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? totalStreak,
  }) {
    return UserStats(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      totalStreak: totalStreak ?? this.totalStreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'totalStreak': totalStreak,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      level: (map['level'] as num?)?.toInt() ?? 1,
      currentXp: (map['currentXp'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (map['xpToNextLevel'] as num?)?.toInt() ?? 500,
      totalStreak: (map['totalStreak'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserStats.fromJson(String source) =>
      UserStats.fromMap(json.decode(source) as Map<String, dynamic>);
}
