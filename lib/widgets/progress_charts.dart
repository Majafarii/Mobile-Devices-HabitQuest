import 'package:flutter/material.dart';

import '../services/progress_tracker.dart';

class ProgressCharts extends StatelessWidget {
  const ProgressCharts({super.key, required this.days});

  final List<DailyProgress> days;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChart(
          context,
          title: 'XP Earned - Last 7 Days',
          valueForDay: (day) => day.xp,
          unit: 'XP',
        ),
        const SizedBox(height: 14),
        _buildChart(
          context,
          title: 'Quests Completed - Last 7 Days',
          valueForDay: (day) => day.completions,
          unit: 'quests',
        ),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context, {
    required String title,
    required int Function(DailyProgress) valueForDay,
    required String unit,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final values = days.map(valueForDay).toList();

    final maximum = values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${values.fold<int>(0, (a, b) => a + b)} $unit',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: Row(
                children: [
                  for (var i = 0; i < days.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Text(
                              '${values[i]}',
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final height = maximum == 0
                                      ? 0.0
                                      : values[i] /
                                            maximum *
                                            constraints.maxHeight;

                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 22,
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _dayLabel(days[i].date),
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
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

  String _dayLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return weekdays[date.weekday - 1];
  }
}
