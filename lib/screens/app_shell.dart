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
    required this.textScaleFactor,
    required this.onDarkModeChanged,
    required this.onTextScaleFactorChanged,
  });

  final bool isDarkMode;
  final double textScaleFactor;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<double> onTextScaleFactorChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _demoNotificationsEnabled = false;
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
      appBar: AppBar(
        title: _selectedIndex == 0 ? null : const Text('HabitQuest'),
      ),
      drawer: _buildDrawer(context),
      body: _selectedIndex == 0
          ? HomeScreen(
              habits: _habits,
              completed: _completed,
              onCompletionChanged: (index, isComplete) {
                _updateCompletion(index, isComplete);
                _showActionSnackBar(
                  isComplete
                      ? 'Quest completed!'
                      : 'Quest marked incomplete',
                );
              },
              onHabitTap: (habit) async {
                final habitIndex = _habits.indexOf(habit);
                if (habitIndex < 0) return;

                final deletedHabit = await Navigator.push<Habit>(
                  context,
                  MaterialPageRoute<Habit>(
                    builder: (context) => QuestDetailScreen(
                      habit: habit,
                      isCompleted: _completed[habitIndex],
                      onCompletionChanged: (isComplete) {
                        _updateCompletion(habitIndex, isComplete);
                      },
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
                _showActionSnackBar('Quest deleted');
              },
            )
          : _selectedIndex == 1
          ? const ProgressScreen()
          : _selectedIndex == 2
          ? const AchievementsScreen()
          : ProfileScreen(
              isDarkMode: widget.isDarkMode,
              demoNotificationsEnabled: _demoNotificationsEnabled,
              textScaleFactor: widget.textScaleFactor,
              onDarkModeChanged: widget.onDarkModeChanged,
              onDemoNotificationsChanged: (isEnabled) {
                setState(() {
                  _demoNotificationsEnabled = isEnabled;
                });
              },
              onTextScaleFactorChanged: widget.onTextScaleFactorChanged,
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
                _showActionSnackBar('Quest created successfully!');
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

  Widget _buildDrawer(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HabitQuest', style: textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text(
                          'Build better habits',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                children: [
                  for (var index = 0; index < _tabs.length; index++)
                    ListTile(
                      selected: _selectedIndex == index,
                      selectedColor: colors.primary,
                      selectedTileColor: colors.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(_tabs[index].icon),
                      title: Text(_tabs[index].title),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCompletion(int index, bool isComplete) {
    if (index < 0 || index >= _completed.length) return;

    setState(() {
      _completed[index] = isComplete;
    });
  }

  void _showActionSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TabInfo {
  const _TabInfo({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
