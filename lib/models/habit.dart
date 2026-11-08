/// A single habit (quest) tracked by a user.
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

  /// Completion flags for the current week, Monday first.
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

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() => {
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

  factory Habit.fromMap(Map<String, dynamic> map) => Habit.fromJson(map);

  factory Habit.fromJson(Map<String, dynamic> json) {
    final weekly = (json['weeklyCompletions'] as List<dynamic>? ?? const [])
        .map((value) => value == true)
        .toList();
    return Habit(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Untitled quest',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'Daily',
      reminderTime: json['reminderTime'] as String?,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
      weeklyCompletions: weekly.length == 7
          ? weekly
          : List<bool>.filled(7, false),
    );
  }
}
