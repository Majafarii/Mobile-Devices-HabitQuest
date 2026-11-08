import 'dart:convert';

/// Habit data model with serialization for local storage persistence.
class Habit {
  const Habit({
    required this.name,
    this.id,
    this.category = 'General',
    this.description = '',
    this.frequency = 'Daily',
    this.reminderTime,
    this.streak = 0,
    this.xpReward = 50,
    this.weeklyCompletions = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
  });

  final String? id;
  final String name;
  final String category;
  final String description;
  final String frequency;
  final String? reminderTime;
  final int streak;
  final int xpReward;
  final List<bool> weeklyCompletions;

  Habit copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? frequency,
    String? reminderTime,
    int? streak,
    int? xpReward,
    List<bool>? weeklyCompletions,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      streak: streak ?? this.streak,
      xpReward: xpReward ?? this.xpReward,
      weeklyCompletions: weeklyCompletions ?? this.weeklyCompletions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? name,
      'name': name,
      'category': category,
      'description': description,
      'frequency': frequency,
      'reminderTime': reminderTime,
      'streak': streak,
      'xpReward': xpReward,
      'weeklyCompletions': weeklyCompletions,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String?,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      reminderTime: map['reminderTime'] as String?,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 50,
      weeklyCompletions: map['weeklyCompletions'] != null
          ? List<bool>.from(map['weeklyCompletions'] as List)
          : const [false, false, false, false, false, false, false],
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) =>
      Habit.fromMap(json.decode(source) as Map<String, dynamic>);
}
