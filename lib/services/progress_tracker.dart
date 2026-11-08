class CompletionRecord {
  const CompletionRecord({
    required this.id,
    required this.habitName,
    required this.completedAt,
    required this.xpEarned,
  });

  final String id;
  final String habitName;
  final DateTime completedAt;
  final int xpEarned;
}

class DailyProgress {
  const DailyProgress({
    required this.date,
    required this.xp,
    required this.completions,
  });

  final DateTime date;
  final int xp;
  final int completions;
}

class ProgressTracker {
  const ProgressTracker(this.records);

  final List<CompletionRecord> records;

  int get totalXp => records.fold(0, (sum, record) => sum + record.xpEarned);

  int get totalCompletions => records.length;

  // Returns the most recent completed quests.
  List<CompletionRecord> get recentCompletions {
    final sorted = List<CompletionRecord>.from(records);

    sorted.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return sorted.take(5).toList();
  }

  // Creates seven days of chart data ending today.
  List<DailyProgress> lastSevenDays(DateTime today) {
    final currentDate = DateTime(today.year, today.month, today.day);

    return List.generate(7, (index) {
      final day = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day - 6 + index,
      );

      var dailyXp = 0;
      var dailyCompletions = 0;

      for (final record in records) {
        if (_sameDay(record.completedAt, day)) {
          dailyXp += record.xpEarned;
          dailyCompletions++;
        }
      }

      return DailyProgress(
        date: day,
        xp: dailyXp,
        completions: dailyCompletions,
      );
    });
  }

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
