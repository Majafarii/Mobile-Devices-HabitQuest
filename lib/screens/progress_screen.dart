import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Progress dashboard built from fixed sample values for the UI prototype.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _xpDays = [
    _XpDay(day: 'M', points: 90, barHeight: 54),
    _XpDay(day: 'T', points: 140, barHeight: 86),
    _XpDay(day: 'W', points: 70, barHeight: 42),
    _XpDay(day: 'T', points: 180, barHeight: 110),
    _XpDay(day: 'F', points: 110, barHeight: 66),
    _XpDay(day: 'S', points: 150, barHeight: 92),
    _XpDay(day: 'S', points: 60, barHeight: 36),
  ];

  static const _recentCompletions = [
    _RecentCompletion(habit: 'Drink Water', xp: 25),
    _RecentCompletion(habit: 'Study 1 Hour', xp: 50),
    _RecentCompletion(habit: 'Read 20 Minutes', xp: 20),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SAMPLE DATA',
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
                  value: '7 days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakCard(
                  context,
                  title: 'Longest Streak',
                  value: '12 days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildXpChartCard(context),
          const SizedBox(height: 24),
          Text('Recent Completions', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final completion in _recentCompletions)
            _buildCompletionTile(context, completion),
        ],
      ),
    );
  }

  Widget _buildXpSummaryCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                Text('Level 4', style: textTheme.titleLarge),
                const Spacer(),
                Text('1,250 total XP', style: textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 14),
            Text('Progress to Level 5', style: textTheme.labelMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const LinearProgressIndicator(
                value: 0.69,
                minHeight: 9,
                color: AppColors.pink,
                backgroundColor: Color(0xFFFFE5EB),
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
        subtitle: const Text('Completed today - Sample XP'),
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
