import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Home tab content populated with demo data until real habit data is connected.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const _habits = [
    _QuestHabit(name: 'Drink Water', category: 'Wellness', streak: 3),
    _QuestHabit(name: 'Study 1 Hour', category: 'Learning', streak: 5),
    _QuestHabit(name: 'Morning Workout', category: 'Fitness', streak: 2),
    _QuestHabit(name: 'Read 20 Minutes', category: 'Reading', streak: 7),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<bool> _completed = List<bool>.filled(
    HomeScreen._habits.length,
    false,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  color: AppColors.surface,
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
                      color: AppColors.secondaryText,
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
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressCard(context),
          const SizedBox(height: 16),
          _buildQuoteCard(context),
          const SizedBox(height: 24),
          Text("Today's Quests", style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var index = 0; index < HomeScreen._habits.length; index++)
            _buildHabitCard(context, index),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
    final habit = HomeScreen._habits[index];
    final isCompleted = _completed[index];
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        title: Text(
          habit.name,
          style: textTheme.titleMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? AppColors.secondaryText
                : AppColors.primaryText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              Text(habit.category, style: textTheme.labelMedium),
              const SizedBox(width: 10),
              const Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: AppColors.streak,
              ),
              const SizedBox(width: 3),
              Text('${habit.streak} day streak', style: textTheme.labelMedium),
            ],
          ),
        ),
        trailing: Checkbox(
          value: isCompleted,
          activeColor: AppColors.success,
          onChanged: (value) {
            setState(() {
              _completed[index] = value ?? false;
            });
          },
        ),
      ),
    );
  }
}

class _QuestHabit {
  const _QuestHabit({
    required this.name,
    required this.category,
    required this.streak,
  });

  final String name;
  final String category;
  final int streak;
}
