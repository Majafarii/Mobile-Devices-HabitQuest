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
}
