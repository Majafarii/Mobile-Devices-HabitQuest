import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Achievement badges displayed with fixed sample unlock states.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _achievements = [
    _Achievement(
      title: 'First Quest',
      description: 'Complete your first quest.',
      icon: Icons.flag_rounded,
      isUnlocked: true,
      color: AppColors.pink,
    ),
    _Achievement(
      title: '7-Day Streak',
      description: 'Keep a quest streak going for seven days.',
      icon: Icons.local_fire_department_rounded,
      isUnlocked: true,
      color: AppColors.streak,
    ),
    _Achievement(
      title: 'Level 5',
      description: 'Reach Level 5 through your quest progress.',
      icon: Icons.stars_rounded,
      isUnlocked: false,
      color: AppColors.information,
    ),
    _Achievement(
      title: '30-Day Streak',
      description: 'Maintain a quest streak for 30 days.',
      icon: Icons.local_fire_department_rounded,
      isUnlocked: false,
      color: AppColors.pink,
    ),
    _Achievement(
      title: '100 Quests',
      description: 'Complete 100 quests.',
      icon: Icons.emoji_events_rounded,
      isUnlocked: false,
      color: AppColors.streak,
    ),
    _Achievement(
      title: 'Perfect Week',
      description: 'Complete all of your quests for a full week.',
      icon: Icons.calendar_month_rounded,
      isUnlocked: false,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

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
          _buildSummaryCard(context),
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
                _buildAchievementCard(context, achievement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
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
                '2 of 6 badges unlocked',
                style: textTheme.titleMedium,
              ),
            ),
            Text('SAMPLE', style: textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, _Achievement achievement) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final iconColor = achievement.isUnlocked
        ? achievement.color
        : colors.onSurfaceVariant;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showAchievementDialog(context, achievement),
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
                  color: achievement.isUnlocked
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
                    achievement.isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    size: 15,
                    color: achievement.isUnlocked
                        ? AppColors.success
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    achievement.isUnlocked ? 'Unlocked' : 'Locked',
                    style: textTheme.labelSmall?.copyWith(
                      color: achievement.isUnlocked
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

  void _showAchievementDialog(BuildContext context, _Achievement achievement) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.title),
        content: Text(achievement.description),
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

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;
}
