import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/services/progress_tracker.dart';

void main() {
  group('Progress Tracker Tests', () {
    final records = [
      CompletionRecord(
        id: 'quest-1',
        habitName: 'Drink Water',
        completedAt: DateTime(2026, 11, 3),
        xpEarned: 25,
      ),
      CompletionRecord(
        id: 'quest-2',
        habitName: 'Read Book',
        completedAt: DateTime(2026, 11, 4),
        xpEarned: 50,
      ),
      CompletionRecord(
        id: 'quest-3',
        habitName: 'Exercise',
        completedAt: DateTime(2026, 11, 4, 15, 30),
        xpEarned: 25,
      ),
    ];

    test('calculates total XP', () {
      final tracker = ProgressTracker(records);

      expect(tracker.totalXp, 100);
    });

    test('counts completed quests', () {
      final tracker = ProgressTracker(records);

      expect(tracker.totalCompletions, 3);
    });

    test('returns seven days of data', () {
      final tracker = ProgressTracker(records);

      final days = tracker.lastSevenDays(DateTime(2026, 11, 5));

      expect(days.length, 7);
    });

    test('calculates daily XP correctly', () {
      final tracker = ProgressTracker(records);

      final days = tracker.lastSevenDays(DateTime(2026, 11, 5));

      expect(days[4].xp, 25);
      expect(days[5].xp, 75);
      expect(days[6].xp, 0);
    });

    test('counts daily completions', () {
      final tracker = ProgressTracker(records);

      final days = tracker.lastSevenDays(DateTime(2026, 11, 5));

      expect(days[5].completions, 2);
    });

    test('returns newest completions first', () {
      final tracker = ProgressTracker(records);

      final recent = tracker.recentCompletions;

      expect(recent.length, 3);
      expect(recent.first.habitName, 'Exercise');
      expect(recent.last.habitName, 'Drink Water');
    });

    test('handles empty history', () {
      const tracker = ProgressTracker([]);

      expect(tracker.totalXp, 0);
      expect(tracker.totalCompletions, 0);
      expect(tracker.recentCompletions, isEmpty);

      final days = tracker.lastSevenDays(DateTime(2026, 11, 5));

      expect(days.every((day) => day.xp == 0), true);
    });

    test('handles dates across month boundaries', () {
      final tracker = ProgressTracker([
        CompletionRecord(
          id: 'oct-quest',
          habitName: 'Study',
          completedAt: DateTime(2026, 10, 31),
          xpEarned: 25,
        ),
      ]);

      final days = tracker.lastSevenDays(DateTime(2026, 11, 3));

      expect(days[3].date.day, 31);
      expect(days[3].xp, 25);
    });
  });
}
