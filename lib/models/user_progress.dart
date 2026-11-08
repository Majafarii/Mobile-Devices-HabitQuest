import 'habit.dart';

/// Persisted record for one completion award.
class UserCompletion {
  const UserCompletion({
    required this.id,
    required this.habitName,
    required this.completedAt,
    required this.xpEarned,
  });

  final String id;
  final String habitName;
  final DateTime completedAt;
  final int xpEarned;

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitName': habitName,
    'completedAt': completedAt.toIso8601String(),
    'xpEarned': xpEarned,
  };

  factory UserCompletion.fromJson(Map<String, dynamic> json) => UserCompletion(
    id: json['id'] as String,
    habitName: json['habitName'] as String? ?? 'Quest',
    completedAt:
        DateTime.tryParse(json['completedAt'] as String? ?? '') ??
        DateTime.now(),
    xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
  );
}

/// Everything that belongs to one account: quests, score and preferences.
class UserProgress {
  UserProgress({
    required this.habits,
    required this.completedToday,
    this.totalXp = 0,
    this.totalCompletions = 0,
    this.longestStreak = 0,
    List<int>? weeklyXp,
    List<UserCompletion>? completionHistory,
    required this.lastActiveDate,
    this.isDarkMode = false,
    this.textScaleFactor = 1.0,
    this.notificationsEnabled = false,
  }) : weeklyXp = weeklyXp ?? List<int>.filled(7, 0),
       completionHistory = completionHistory ?? [];

  /// Fallback reward for legacy or invalid habits without an XP reward.
  static const xpPerCompletion = 25;

  final List<Habit> habits;
  final List<bool> completedToday;
  int totalXp;
  int totalCompletions;
  int longestStreak;

  /// XP earned on each day of the current week, Monday first.
  final List<int> weeklyXp;
  final List<UserCompletion> completionHistory;

  /// Last day (local date) the account was used; drives daily/weekly resets.
  DateTime lastActiveDate;

  bool isDarkMode;
  double textScaleFactor;
  bool notificationsEnabled;

  int get level {
    var currentLevel = 1;
    while (totalXp >= xpRequiredForLevel(currentLevel + 1)) {
      currentLevel++;
    }
    return currentLevel;
  }

  static int xpRequiredForLevel(int level) {
    if (level < 1) throw ArgumentError.value(level, 'level');
    return 50 * level * (level - 1);
  }

  int get xpIntoLevel => totalXp - xpRequiredForLevel(level);
  int get xpNeededForNextLevel =>
      xpRequiredForLevel(level + 1) - xpRequiredForLevel(level);
  double get levelProgress => xpIntoLevel / xpNeededForNextLevel;

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
        id: 'drink-water',
        name: 'Drink Water',
        category: 'Wellness',
        description:
            'Keep a water bottle nearby and stay hydrated throughout the day.',
        xpReward: xpPerCompletion,
      ),
      Habit(
        id: 'study-one-hour',
        name: 'Study 1 Hour',
        category: 'Learning',
        description:
            'Spend one focused hour reviewing coursework or class notes.',
        xpReward: xpPerCompletion,
      ),
      Habit(
        id: 'morning-workout',
        name: 'Morning Workout',
        category: 'Fitness',
        description:
            'Make time for a short workout to start the morning with energy.',
        xpReward: xpPerCompletion,
      ),
      Habit(
        id: 'read-twenty-minutes',
        name: 'Read 20 Minutes',
        category: 'Reading',
        description:
            'Read a book or other useful material for at least 20 minutes.',
        xpReward: xpPerCompletion,
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

  /// Marks quest [index] complete or incomplete today and updates its score.
  void setCompletion(
    int index,
    bool isComplete,
    DateTime now, {
    int? xpEarned,
    String? completionId,
  }) {
    if (index < 0 || index >= habits.length || index >= completedToday.length) {
      return;
    }
    if (completedToday[index] == isComplete) return;

    final weekday = now.weekday - 1;
    final habit = habits[index];
    final id = completionId ?? _completionId(habit, index, now);
    final reward = xpEarned ?? _rewardFor(habit);
    final weekly = List<bool>.of(habit.weeklyCompletions);
    weekly[weekday] = isComplete;

    if (isComplete && completionHistory.any((record) => record.id == id)) {
      completedToday[index] = true;
      habits[index] = habit.copyWith(weeklyCompletions: weekly);
      return;
    }

    completedToday[index] = isComplete;
    habits[index] = habit.copyWith(
      streak: (habit.streak + (isComplete ? 1 : -1)).clamp(0, 1 << 30),
      weeklyCompletions: weekly,
    );

    if (isComplete) {
      totalCompletions++;
      totalXp += reward;
      weeklyXp[weekday] += reward;
      completionHistory.add(
        UserCompletion(
          id: id,
          habitName: habit.name,
          completedAt: now,
          xpEarned: reward,
        ),
      );
      if (habits[index].streak > longestStreak) {
        longestStreak = habits[index].streak;
      }
    } else {
      final recordIndex = completionHistory.indexWhere(
        (record) => record.id == id,
      );
      final removed = recordIndex < 0
          ? null
          : completionHistory.removeAt(recordIndex);
      final reversedReward = removed?.xpEarned ?? reward;
      totalCompletions = (totalCompletions - 1).clamp(0, 1 << 30);
      totalXp = (totalXp - reversedReward).clamp(0, 1 << 30);
      final recordWeekday = removed?.completedAt.weekday ?? now.weekday;
      weeklyXp[recordWeekday - 1] =
          (weeklyXp[recordWeekday - 1] - reversedReward).clamp(0, 1 << 30);
    }
  }

  void addHabit(Habit habit) {
    habits.add(habit);
    completedToday.add(false);
  }

  void removeHabitAt(int index) {
    if (index < 0 || index >= habits.length) return;
    habits.removeAt(index);
    if (index < completedToday.length) completedToday.removeAt(index);
  }

  /// Resets today's checkboxes on a new day and weekly stats on a new week.
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
    'completionHistory': [
      for (final completion in completionHistory) completion.toJson(),
    ],
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
    while (completed.length < habits.length) {
      completed.add(false);
    }
    if (completed.length > habits.length) {
      completed.removeRange(habits.length, completed.length);
    }
    final weeklyXp = (json['weeklyXp'] as List<dynamic>? ?? const [])
        .map((value) => (value as num).toInt())
        .toList();
    final history = [
      for (final record
          in json['completionHistory'] as List<dynamic>? ?? const [])
        UserCompletion.fromJson(Map<String, dynamic>.from(record as Map)),
    ];

    return UserProgress(
      habits: habits,
      completedToday: completed,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      weeklyXp: weeklyXp.length == 7 ? weeklyXp : null,
      completionHistory: history,
      lastActiveDate: _dateOnly(
        DateTime.tryParse(json['lastActiveDate'] as String? ?? '') ??
            DateTime.now(),
      ),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
    );
  }

  static int _rewardFor(Habit habit) =>
      habit.xpReward > 0 ? habit.xpReward : xpPerCompletion;

  static String _completionId(Habit habit, int index, DateTime now) {
    final habitId = habit.id ?? 'habit-$index';
    return '$habitId-${now.year}-${now.month}-${now.day}';
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _startOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
