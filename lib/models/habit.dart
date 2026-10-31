/// Basic in-memory habit data used by the UI.
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
  final List<bool> weeklyCompletions;
}
