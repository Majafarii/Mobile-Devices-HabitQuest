/// Basic habit data model expanded with identity and gamification attributes.
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
}
