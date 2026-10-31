import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../widgets/add_habit_dialog.dart';

/// Shows demo details for the quest selected on the Home screen.
class QuestDetailScreen extends StatefulWidget {
  const QuestDetailScreen({
    super.key,
    required this.habit,
    required this.onHabitUpdated,
  });

  final Habit habit;
  final ValueChanged<Habit> onHabitUpdated;

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  late Habit _habit;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
  }

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
            Text(_habit.name, style: textTheme.headlineLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  color: AppColors.information,
                ),
                const SizedBox(width: 8),
                Text(_habit.category, style: textTheme.bodyLarge),
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
                    Text(
                      _habit.description.isEmpty
                          ? 'No notes added.'
                          : _habit.description,
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.repeat_rounded),
                title: Text('${_habit.frequency} quest'),
                subtitle: Text(
                  _habit.reminderTime == null
                      ? 'No reminder set'
                      : 'Reminder at ${_habit.reminderTime}',
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
                          Text(
                            '${_habit.streak} days',
                            style: textTheme.titleLarge,
                          ),
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
                onPressed: _editHabit,
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
    final isComplete = index < _habit.weeklyCompletions.length
        ? _habit.weeklyCompletions[index]
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

  Future<void> _editHabit() async {
    final updatedHabit = await showDialog<Habit>(
      context: context,
      builder: (context) => AddHabitDialog(habitToEdit: _habit),
    );

    if (!mounted) return;
    if (updatedHabit == null) return;

    setState(() {
      _habit = updatedHabit;
    });
    widget.onHabitUpdated(updatedHabit);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quest updated!')));
  }
}
