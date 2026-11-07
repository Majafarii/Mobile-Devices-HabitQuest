import 'package:flutter/material.dart';

import '../models/user_progress.dart';
import '../theme/app_colors.dart';

/// Progress dashboard for the signed-in account's score and streaks.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.progress});

  final UserProgress progress;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _maxBarHeight = 110.0;

  List<_XpDay> get _xpDays {
    final maxXp = progress.weeklyXp.fold<int>(0, (a, b) => a > b ? a : b);
    return [
      for (var i = 0; i < 7; i++)
        _XpDay(
          day: _dayLabels[i],
          points: progress.weeklyXp[i],
          barHeight: maxXp == 0
              ? 4
              : 4 + (_maxBarHeight - 4) * progress.weeklyXp[i] / maxXp,
        ),
    ];
  }

  List<_RecentCompletion> get _recentCompletions => [
    for (var i = 0; i < progress.habits.length; i++)
      if (progress.completedToday[i])
        _RecentCompletion(
          habit: progress.habits[i].name,
          xp: UserProgress.xpPerCompletion,
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
          Row(
            children: [
              Expanded(child: Text('Progress', style: textTheme.displayLarge)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.totalCompletions} QUESTS DONE',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildXpSummaryCard(context),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(
                  context,
                  title: 'Current Streak',
                  value: _days(progress.currentStreak),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakCard(
                  context,
                  title: 'Longest Streak',
                  value: _days(progress.longestStreak),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildXpChartCard(context),
          const SizedBox(height: 24),
          Text('Recent Completions', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_recentCompletions.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.hourglass_empty_rounded),
                title: const Text('No quests completed yet today'),
                subtitle: const Text('Complete a quest on Home to earn XP.'),
              ),
            )
          else
            for (final completion in _recentCompletions)
              _buildCompletionTile(context, completion),
        ],
      ),
    );
  }

  static String _days(int count) => count == 1 ? '1 day' : '$count days';

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
                Expanded(
                  child: Text(
                    'Level ${progress.level}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${progress.totalXp} total XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Progress to Level ${progress.level + 1}',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress.levelProgress,
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

  Widget _buildStreakCard(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.streak,
            ),
            const SizedBox(height: 8),
            Text(title, style: textTheme.labelMedium),
            const SizedBox(height: 3),
            Text(value, style: textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildXpChartCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('XP This Week', style: textTheme.titleMedium),
            const SizedBox(height: 18),
            SizedBox(
              height: 156,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in _xpDays)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${day.points}', style: textTheme.labelSmall),
                          const SizedBox(height: 5),
                          Container(
                            width: 20,
                            height: day.barHeight,
                            decoration: BoxDecoration(
                              color: AppColors.pink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(day.day, style: textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionTile(
    BuildContext context,
    _RecentCompletion completion,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
        ),
        title: Text(completion.habit, style: textTheme.titleMedium),
        subtitle: const Text('Completed today'),
        trailing: Text('+${completion.xp} XP', style: textTheme.labelMedium),
      ),
    );
  }
}

class _XpDay {
  const _XpDay({
    required this.day,
    required this.points,
    required this.barHeight,
  });

  final String day;
  final int points;
  final double barHeight;
}

class _RecentCompletion {
  const _RecentCompletion({required this.habit, required this.xp});

  final String habit;
  final int xp;
}
