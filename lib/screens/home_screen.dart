import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';

/// Home tab content populated with demo data until real habit data is connected.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.habits,
    required this.completed,
    required this.onCompletionChanged,
    required this.onHabitTap,
  });

  final List<Habit> habits;
  final List<bool> completed;
  final void Function(int index, bool isComplete) onCompletionChanged;
  final ValueChanged<Habit> onHabitTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('HabitQuest', style: textTheme.displayLarge),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    'DEMO DATA',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Build consistency, one quest at a time.',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressCard(context),
          const SizedBox(height: 16),
          _buildQuoteCard(context),
          const SizedBox(height: 24),
          Text("Today's Quests", style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (habits.isEmpty)
            _buildEmptyState(context)
          else
            for (var index = 0; index < habits.length; index++)
              _buildHabitCard(context, index),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
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
                Icon(Icons.stars_rounded, color: AppColors.pink),
                const SizedBox(width: 8),
                Text('Level 4', style: textTheme.titleLarge),
                const Spacer(),
                Text('1,250 / 1,800 XP', style: textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: 0.69,
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

  Widget _buildQuoteCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote_rounded, color: AppColors.pink),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Small steps every day lead to big changes.',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A reminder from HabitQuest',
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, int index) {
    final habit = habits[index];
    final isCompleted = completed[index];
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        onTap: () => onHabitTap(habit),
        title: Text(
          habit.name,
          style: textTheme.titleMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${habit.category} - ${habit.frequency}',
                style: textTheme.labelMedium,
              ),
              if (habit.description.isNotEmpty)
                Text(
                  habit.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall,
                ),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 17,
                    color: AppColors.streak,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${habit.streak} day streak',
                    style: textTheme.labelMedium,
                  ),
                  if (habit.reminderTime != null) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded, size: 15),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        habit.reminderTime!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        trailing: Checkbox(
          value: isCompleted,
          activeColor: AppColors.success,
          onChanged: (value) => onCompletionChanged(index, value ?? false),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.flag_outlined, size: 34, color: AppColors.pink),
            const SizedBox(height: 10),
            Text('No quests yet', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Add a habit to start building your journey.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
