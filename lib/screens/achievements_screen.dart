import 'package:flutter/material.dart';

import '../services/achievement_engine.dart';
import '../theme/app_colors.dart';

/// Displays achievements based on the user's actual progress.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.progress});

  final AchievementProgress progress;

  static const _achievements = [
    _Achievement(
      type: AchievementType.firstQuest,
      title: 'First Quest',
      description: 'Complete your first quest.',
      icon: Icons.flag_rounded,
      color: AppColors.pink,
    ),
    _Achievement(
      type: AchievementType.sevenDayStreak,
      title: '7-Day Streak',
      description: 'Keep a quest streak going for seven days.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.streak,
    ),
    _Achievement(
      type: AchievementType.levelFive,
      title: 'Level 5',
      description: 'Reach Level 5 through your quest progress.',
      icon: Icons.stars_rounded,
      color: AppColors.information,
    ),
    _Achievement(
      type: AchievementType.thirtyDayStreak,
      title: '30-Day Streak',
      description: 'Maintain a quest streak for 30 days.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.pink,
    ),
    _Achievement(
      type: AchievementType.hundredQuests,
      title: '100 Quests',
      description: 'Complete 100 quests.',
      icon: Icons.emoji_events_rounded,
      color: AppColors.streak,
    ),
    _Achievement(
      type: AchievementType.perfectWeek,
      title: 'Perfect Week',
      description: 'Complete all your quests for a full week.',
      icon: Icons.calendar_month_rounded,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    // Calculate unlocked badges using the Achievement Engine.
    final unlocked = AchievementEngine.unlockedAchievements(progress);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Achievements', style: textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(
            'Earn badges by completing quests and building healthy habits.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Summary now uses calculated achievement progress.
          _buildSummaryCard(context, unlocked.length),

          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final achievement in _achievements)
                _buildAchievementCard(
                  context,
                  achievement,
                  unlocked.contains(achievement.type),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int unlockedCount) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: AppColors.pink),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$unlockedCount of '
                '${_achievements.length} badges unlocked',
                style: textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    _Achievement achievement,
    bool isUnlocked,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final iconColor = isUnlocked ? achievement.color : colors.onSurfaceVariant;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showAchievementDialog(context, achievement, isUnlocked),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(achievement.icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  achievement.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    size: 15,
                    color: isUnlocked
                        ? AppColors.success
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isUnlocked ? 'Unlocked' : 'Locked',
                    style: textTheme.labelSmall?.copyWith(
                      color: isUnlocked
                          ? AppColors.success
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shows more information when the user taps a badge.
  void _showAchievementDialog(
    BuildContext context,
    _Achievement achievement,
    bool isUnlocked,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock_outline,
                  size: 18,
                  color: isUnlocked
                      ? AppColors.success
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(isUnlocked ? 'Achievement unlocked!' : 'Not unlocked yet'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Stores the visual information for each achievement.
class _Achievement {
  const _Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
