import 'habit.dart';

/// Everything that belongs to one account: quests, score and preferences.
///
/// Each account has its own [UserProgress], saved separately so signing in
/// as a different user shows only that user's data.
class UserProgress {
  UserProgress({
    required this.habits,
    required this.completedToday,
    this.totalXp = 0,
    this.totalCompletions = 0,
    this.longestStreak = 0,
    List<int>? weeklyXp,
    required this.lastActiveDate,
    this.isDarkMode = false,
    this.textScaleFactor = 1.0,
    this.notificationsEnabled = false,
  }) : weeklyXp = weeklyXp ?? List<int>.filled(7, 0);

  /// XP earned for each completed quest.
  static const xpPerCompletion = 25;

  /// XP needed to advance one level.
  static const xpPerLevel = 500;

  final List<Habit> habits;
  final List<bool> completedToday;
  int totalXp;
  int totalCompletions;
  int longestStreak;

  /// XP earned on each day of the current week, Monday first.
  final List<int> weeklyXp;

  /// Last day (local date) the account was used; drives daily/weekly resets.
  DateTime lastActiveDate;

  bool isDarkMode;
  double textScaleFactor;
  bool notificationsEnabled;

  int get level => totalXp ~/ xpPerLevel + 1;
  int get xpIntoLevel => totalXp % xpPerLevel;
  double get levelProgress => xpIntoLevel / xpPerLevel;

  int get currentStreak => habits.fold(
    0,
    (best, habit) => habit.streak > best ? habit.streak : best,
  );

  int get completedTodayCount =>
      completedToday.where((isComplete) => isComplete).length;

  /// Starting data for a brand-new account.
  factory UserProgress.newAccount(DateTime now) {
    const starterHabits = [
      Habit(
        name: 'Drink Water',
        category: 'Wellness',
        description:
            'Keep a water bottle nearby and stay hydrated throughout the day.',
      ),
      Habit(
        name: 'Study 1 Hour',
        category: 'Learning',
        description:
            'Spend one focused hour reviewing coursework or class notes.',
      ),
      Habit(
        name: 'Morning Workout',
        category: 'Fitness',
        description:
            'Make time for a short workout to start the morning with energy.',
      ),
      Habit(
        name: 'Read 20 Minutes',
        category: 'Reading',
        description:
            'Read a book or other useful material for at least 20 minutes.',
      ),
    ];
    return UserProgress(
      habits: List<Habit>.of(starterHabits),
      completedToday: List<bool>.filled(
        starterHabits.length,
        false,
        growable: true,
      ),
      lastActiveDate: _dateOnly(now),
    );
  }

  /// Marks quest [index] complete or incomplete today and updates the score.
  void setCompletion(int index, bool isComplete, DateTime now) {
    if (index < 0 || index >= habits.length) return;
    if (completedToday[index] == isComplete) return;

    final weekday = now.weekday - 1;
    final habit = habits[index];
    final weekly = List<bool>.of(habit.weeklyCompletions);
    weekly[weekday] = isComplete;
    final delta = isComplete ? 1 : -1;

    completedToday[index] = isComplete;
    habits[index] = habit.copyWith(
      streak: (habit.streak + delta).clamp(0, 1 << 30),
      weeklyCompletions: weekly,
    );
    totalCompletions = (totalCompletions + delta).clamp(0, 1 << 30);
    totalXp = (totalXp + delta * xpPerCompletion).clamp(0, 1 << 30);
    weeklyXp[weekday] = (weeklyXp[weekday] + delta * xpPerCompletion).clamp(
      0,
      1 << 30,
    );
    if (habits[index].streak > longestStreak) {
      longestStreak = habits[index].streak;
    }
  }

  void addHabit(Habit habit) {
    habits.add(habit);
    completedToday.add(false);
  }

  void removeHabitAt(int index) {
    habits.removeAt(index);
    completedToday.removeAt(index);
  }

  /// Resets today's checkboxes on a new day, breaks streaks for quests that
  /// were missed, and clears weekly stats when a new week starts.
  ///
  /// Returns true if anything changed.
  bool rollOver(DateTime now) {
    final today = _dateOnly(now);
    if (!today.isAfter(lastActiveDate)) return false;

    final daysAway = today.difference(lastActiveDate).inDays;
    final isNewWeek = !_startOfWeek(today)
        .isAtSameMomentAs(_startOfWeek(lastActiveDate));

    for (var i = 0; i < habits.length; i++) {
      final missed = daysAway > 1 || !completedToday[i];
      habits[i] = habits[i].copyWith(
        streak: missed ? 0 : habits[i].streak,
        weeklyCompletions: isNewWeek ? List<bool>.filled(7, false) : null,
      );
      completedToday[i] = false;
    }
    if (isNewWeek) weeklyXp.fillRange(0, 7, 0);
    lastActiveDate = today;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'habits': [for (final habit in habits) habit.toJson()],
    'completedToday': completedToday,
    'totalXp': totalXp,
    'totalCompletions': totalCompletions,
    'longestStreak': longestStreak,
    'weeklyXp': weeklyXp,
    'lastActiveDate': lastActiveDate.toIso8601String(),
    'isDarkMode': isDarkMode,
    'textScaleFactor': textScaleFactor,
    'notificationsEnabled': notificationsEnabled,
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final habits = [
      for (final habit in json['habits'] as List<dynamic>? ?? const [])
        Habit.fromJson(Map<String, dynamic>.from(habit as Map)),
    ];
    final completed = (json['completedToday'] as List<dynamic>? ?? const [])
        .map((value) => value == true)
        .toList();
    // Keep the completion list aligned with the habits list.
    while (completed.length < habits.length) {
      completed.add(false);
    }
    if (completed.length > habits.length) {
      completed.removeRange(habits.length, completed.length);
    }
    final weeklyXp = (json['weeklyXp'] as List<dynamic>? ?? const [])
        .map((value) => (value as num).toInt())
        .toList();

    return UserProgress(
      habits: habits,
      completedToday: completed,
      totalXp: json['totalXp'] as int? ?? 0,
      totalCompletions: json['totalCompletions'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      weeklyXp: weeklyXp.length == 7 ? weeklyXp : null,
      lastActiveDate: _dateOnly(
        DateTime.tryParse(json['lastActiveDate'] as String? ?? '') ??
            DateTime.now(),
      ),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _startOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
