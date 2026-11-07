/// A single habit ("quest") tracked by a user.
class Habit {
  const Habit({
    required this.name,
    this.category = 'General',
    this.description = '',
    this.frequency = 'Daily',
    this.reminderTime,
    this.streak = 0,
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

  final String name;
  final String category;
  final String description;
  final String frequency;
  final String? reminderTime;
  final int streak;

  /// Completion flags for the current week, Monday first.
  final List<bool> weeklyCompletions;

  Habit copyWith({int? streak, List<bool>? weeklyCompletions}) {
    return Habit(
      name: name,
      category: category,
      description: description,
      frequency: frequency,
      reminderTime: reminderTime,
      streak: streak ?? this.streak,
      weeklyCompletions: weeklyCompletions ?? this.weeklyCompletions,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'description': description,
    'frequency': frequency,
    'reminderTime': reminderTime,
    'streak': streak,
    'weeklyCompletions': weeklyCompletions,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final weekly = (json['weeklyCompletions'] as List<dynamic>? ?? const [])
        .map((value) => value == true)
        .toList();
    return Habit(
      name: json['name'] as String? ?? 'Untitled quest',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'Daily',
      reminderTime: json['reminderTime'] as String?,
      streak: json['streak'] as int? ?? 0,
      weeklyCompletions: weekly.length == 7
          ? weekly
          : List<bool>.filled(7, false),
    );
  }
}
