import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows demo details for the quest selected on the Home screen.
class QuestDetailScreen extends StatelessWidget {
  const QuestDetailScreen({
    super.key,
    required this.name,
    required this.category,
    required this.description,
    required this.streak,
    required this.weeklyCompletions,
  });

  final String name;
  final String category;
  final String description;
  final int streak;
  final List<bool> weeklyCompletions;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Quest Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(name, style: textTheme.headlineLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  color: AppColors.information,
                ),
                const SizedBox(width: 8),
                Text(category, style: textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description / Notes', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(description, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.streak,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current streak', style: textTheme.labelMedium),
                          const SizedBox(height: 3),
                          Text('$streak days', style: textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Week', style: textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var index = 0; index < _dayLabels.length; index++)
                          _buildDayIndicator(context, index),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Quest will be available soon.'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delete Quest will be available soon. Nothing was deleted.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: AppColors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayIndicator(BuildContext context, int index) {
    final isComplete = index < weeklyCompletions.length
        ? weeklyCompletions[index]
        : false;
    final colors = Theme.of(context).colorScheme;
    final color = isComplete ? AppColors.success : colors.onSurfaceVariant;

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : Icons.remove_rounded,
            size: 19,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(_dayLabels[index], style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
