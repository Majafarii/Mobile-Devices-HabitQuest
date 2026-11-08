enum AchievementType {
  firstQuest,
  sevenDayStreak,
  levelFive,
  thirtyDayStreak,
  hundredQuests,
  perfectWeek,
}

class AchievementProgress {
  const AchievementProgress({
    required this.totalCompletions,
    required this.level,
    required this.longestStreak,
    required this.hasPerfectWeek,
  });

  final int totalCompletions;
  final int level;
  final int longestStreak;
  final bool hasPerfectWeek;
}

class AchievementEngine {
  // Checks whether a single achievement has been earned.
  static bool isUnlocked(
    AchievementType achievement,
    AchievementProgress progress,
  ) {
    switch (achievement) {
      case AchievementType.firstQuest:
        return progress.totalCompletions >= 1;

      case AchievementType.sevenDayStreak:
        return progress.longestStreak >= 7;

      case AchievementType.levelFive:
        return progress.level >= 5;

      case AchievementType.thirtyDayStreak:
        return progress.longestStreak >= 30;

      case AchievementType.hundredQuests:
        return progress.totalCompletions >= 100;

      case AchievementType.perfectWeek:
        return progress.hasPerfectWeek;
    }
  }

  // Returns every achievement the user qualifies for.
  static Set<AchievementType> unlockedAchievements(
    AchievementProgress progress,
  ) {
    return AchievementType.values
        .where((achievement) => isUnlocked(achievement, progress))
        .toSet();
  }

  // Finds achievements unlocked since the previous check.
  static Set<AchievementType> newlyUnlocked({
    required Set<AchievementType> previouslyUnlocked,
    required AchievementProgress currentProgress,
  }) {
    final currentAchievements = unlockedAchievements(currentProgress);

    return currentAchievements.difference(previouslyUnlocked);
  }
}
