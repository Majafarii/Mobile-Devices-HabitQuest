import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/services/achievement_engine.dart';

void main() {
  group('Achievement Engine Tests', () {
    test('First Quest unlocks after one completion', () {
      const progress = AchievementProgress(
        totalCompletions: 1,
        level: 1,
        longestStreak: 0,
        hasPerfectWeek: false,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.firstQuest, progress),
        true,
      );
    });

    test('7-Day Streak unlocks after seven days', () {
      const progress = AchievementProgress(
        totalCompletions: 7,
        level: 2,
        longestStreak: 7,
        hasPerfectWeek: false,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.sevenDayStreak, progress),
        true,
      );
    });

    test('Level 5 stays locked at Level 4', () {
      const progress = AchievementProgress(
        totalCompletions: 20,
        level: 4,
        longestStreak: 5,
        hasPerfectWeek: false,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.levelFive, progress),
        false,
      );
    });

    test('Level 5 unlocks once reached', () {
      const progress = AchievementProgress(
        totalCompletions: 40,
        level: 5,
        longestStreak: 5,
        hasPerfectWeek: false,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.levelFive, progress),
        true,
      );
    });

    test('100 Quests unlocks at 100 completions', () {
      const progress = AchievementProgress(
        totalCompletions: 100,
        level: 6,
        longestStreak: 10,
        hasPerfectWeek: false,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.hundredQuests, progress),
        true,
      );
    });

    test('Perfect Week unlocks when completed', () {
      const progress = AchievementProgress(
        totalCompletions: 14,
        level: 3,
        longestStreak: 7,
        hasPerfectWeek: true,
      );

      expect(
        AchievementEngine.isUnlocked(AchievementType.perfectWeek, progress),
        true,
      );
    });

    test('detects newly unlocked achievements', () {
      const progress = AchievementProgress(
        totalCompletions: 7,
        level: 2,
        longestStreak: 7,
        hasPerfectWeek: true,
      );

      final newlyUnlocked = AchievementEngine.newlyUnlocked(
        previouslyUnlocked: {AchievementType.firstQuest},
        currentProgress: progress,
      );

      expect(newlyUnlocked, {
        AchievementType.sevenDayStreak,
        AchievementType.perfectWeek,
      });
    });

    test('new user starts with no achievements', () {
      const progress = AchievementProgress(
        totalCompletions: 0,
        level: 1,
        longestStreak: 0,
        hasPerfectWeek: false,
      );

      expect(AchievementEngine.unlockedAchievements(progress), isEmpty);
    });
  });
}
