import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../widgets/add_habit_dialog.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'quest_detail_screen.dart';

/// Owns the app's top-level tab selection and keeps navigation visible.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final List<bool> _completed;
  final List<Habit> _habits = [
    const Habit(
      name: 'Drink Water',
      category: 'Wellness',
      description:
          'Keep a water bottle nearby and stay hydrated throughout the day.',
      frequency: 'Daily',
      streak: 3,
      weeklyCompletions: [true, true, false, true, true, false, true],
    ),
    const Habit(
      name: 'Study 1 Hour',
      category: 'Learning',
      description:
          'Spend one focused hour reviewing coursework or class notes.',
      frequency: 'Daily',
      streak: 5,
      weeklyCompletions: [true, true, true, true, false, true, false],
    ),
    const Habit(
      name: 'Morning Workout',
      category: 'Fitness',
      description:
          'Make time for a short workout to start the morning with energy.',
      frequency: 'Daily',
      streak: 2,
      weeklyCompletions: [false, true, true, false, true, false, false],
    ),
    const Habit(
      name: 'Read 20 Minutes',
      category: 'Reading',
      description:
          'Read a book or other useful material for at least 20 minutes.',
      frequency: 'Daily',
      streak: 7,
      weeklyCompletions: [true, true, true, true, true, true, true],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _completed = List<bool>.filled(_habits.length, false, growable: true);
  }

  static const _tabs = [
    _TabInfo(title: 'Home', icon: Icons.home_outlined),
    _TabInfo(title: 'Progress', icon: Icons.insights_outlined),
    _TabInfo(title: 'Achievements', icon: Icons.emoji_events_outlined),
    _TabInfo(title: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(title: const Text('HabitQuest')),
      body: _selectedIndex == 0
          ? HomeScreen(
              habits: _habits,
              completed: _completed,
              onCompletionChanged: (index, isComplete) {
                setState(() {
                  _completed[index] = isComplete;
                });
              },
              onHabitTap: (habit) async {
                final habitIndex = _habits.indexOf(habit);
                if (habitIndex < 0) return;

                final deletedHabit = await Navigator.push<Habit>(
                  context,
                  MaterialPageRoute<Habit>(
                    builder: (context) => QuestDetailScreen(
                      habit: habit,
                      onHabitUpdated: (updatedHabit) {
                        if (!mounted || habitIndex < 0) return;
                        setState(() {
                          _habits[habitIndex] = updatedHabit;
                        });
                      },
                    ),
                  ),
                );
                if (!context.mounted || deletedHabit == null) return;

                final deletedIndex = _habits.indexOf(deletedHabit);
                if (deletedIndex < 0) return;
                setState(() {
                  _habits.removeWhere(
                    (habitInList) => identical(habitInList, deletedHabit),
                  );
                  _completed.removeAt(deletedIndex);
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Quest deleted')));
              },
            )
          : _selectedIndex == 1
          ? const ProgressScreen()
          : _selectedIndex == 2
          ? const AchievementsScreen()
          : ProfileScreen(
              isDarkMode: widget.isDarkMode,
              onDarkModeChanged: widget.onDarkModeChanged,
            ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final newHabit = await showDialog<Habit>(
                  context: context,
                  builder: (context) => const AddHabitDialog(),
                );
                if (!context.mounted) return;
                if (newHabit == null) return;

                setState(() {
                  _habits.add(newHabit);
                  _completed.add(false);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quest created successfully!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.title),
        ],
      ),
    );
  }
}

class _TabInfo {
  const _TabInfo({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
