import 'package:flutter/material.dart';

import '../services/xp_engine.dart';
import '../services/progress_tracker.dart';
import '../theme/app_colors.dart';
import '../widgets/progress_charts.dart';

/// Shows real XP, completion history, and progress charts.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.xpEngine,
    required this.records,
  });

  final XpEngine xpEngine;
  final List<CompletionRecord> records;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    // Calculate dashboard values from actual completion records.
    final tracker = ProgressTracker(records);
    final days = tracker.lastSevenDays(DateTime.now());

    final weeklyXp = days.fold<int>(0, (total, day) => total + day.xp);

    final weeklyCompletions = days.fold<int>(
      0,
      (total, day) => total + day.completions,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Progress', style: textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(
            'Track your XP and completed quests over time.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Level and XP progress.
          _buildXpSummaryCard(context),

          const SizedBox(height: 14),

          // Statistics calculated from actual records.
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'XP This Week',
                  value: '$weeklyXp XP',
                  icon: Icons.stars_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Quests This Week',
                  value: '$weeklyCompletions',
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Reusable charts created in Stage 3.
          ProgressCharts(days: days),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Text('Recent Completions', style: textTheme.titleLarge),
              ),
              Text(
                '${tracker.totalCompletions} total',
                style: textTheme.labelMedium,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Display an empty state if there is no activity yet.
          if (tracker.recentCompletions.isEmpty)
            _buildEmptyState(context)
          else
            for (final completion in tracker.recentCompletions)
              _buildCompletionTile(context, completion),
        ],
      ),
    );
  }

  Widget _buildXpSummaryCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.pink),
                const SizedBox(width: 8),
                Text('Level ${xpEngine.level}', style: textTheme.titleLarge),
                const Spacer(),
                Flexible(
                  child: Text(
                    '${xpEngine.totalXp} total XP',
                    style: textTheme.labelMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Progress to Level ${xpEngine.level + 1}',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 5),
            Text(
              '${xpEngine.currentLevelXp} / '
              '${xpEngine.xpNeededForNextLevel} XP',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: xpEngine.levelProgress,
                minHeight: 9,
                color: AppColors.pink,
                backgroundColor: colors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.pink),
            const SizedBox(height: 8),
            Text(title, style: textTheme.labelMedium),
            const SizedBox(height: 5),
            Text(value, style: textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionTile(
    BuildContext context,
    CompletionRecord completion,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final date = completion.completedAt;

    // Format date and time without additional packages.
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    final formattedDate =
        '${date.month}/${date.day}/${date.year} '
        '$hour:$minute $period';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
        ),
        title: Text(completion.habitName, style: textTheme.titleMedium),
        subtitle: Text('Completed $formattedDate', style: textTheme.bodySmall),
        trailing: Text(
          '+${completion.xpEarned} XP',
          style: textTheme.labelMedium,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.insights_outlined, size: 36, color: colors.primary),
            const SizedBox(height: 12),
            Text('No completions yet', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Complete your first quest to start '
              'tracking your progress!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
