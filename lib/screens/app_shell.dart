import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/xp_engine.dart';
import '../services/achievement_engine.dart';
import '../services/progress_tracker.dart';
import '../widgets/add_habit_dialog.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'quest_detail_screen.dart';

/// Manages the main navigation, habits, and gamification state.
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

  // XP and progress tracking.
  final XpEngine _xpEngine = XpEngine();
  final List<CompletionRecord> _completionRecords = [];

  // IDs prevent XP from being assigned to the wrong habit.
  late final List<String> _habitIds;
  int _nextHabitId = 0;

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

    _habitIds = List.generate(_habits.length, (_) => 'habit-${_nextHabitId++}');
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

      // Display the selected screen.
      body: _buildSelectedScreen(context),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _addHabit,
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

  // Builds the selected tab and provides its required data.
  Widget _buildSelectedScreen(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          habits: _habits,
          completed: _completed,
          xpEngine: _xpEngine,
          onCompletionChanged: (index, isComplete) {
            final previousXp = _xpEngine.totalXp;

            _updateCompletion(index, isComplete);

            final xpDifference = _xpEngine.totalXp - previousXp;

            if (xpDifference > 0) {
              _showActionSnackBar('Quest completed! +$xpDifference XP');
            } else if (xpDifference < 0) {
              _showActionSnackBar('Quest marked incomplete. $xpDifference XP');
            } else {
              _showActionSnackBar(
                isComplete
                    ? 'Quest already rewarded today'
                    : 'Quest marked incomplete',
              );
            }
          },
          onHabitTap: _openHabitDetails,
        );

      case 1:
        // Live Progress Dashboard integration.
        return ProgressScreen(xpEngine: _xpEngine, records: _completionRecords);

      case 2:
        // Evaluate achievements using actual XP and completions.
        // Historical streak data is not yet available.
        final achievementProgress = AchievementProgress(
          totalCompletions: _completionRecords.length,
          level: _xpEngine.level,
          longestStreak: 0,
          hasPerfectWeek: false,
        );

        return AchievementsScreen(progress: achievementProgress);

      case 3:
        return ProfileScreen(
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
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Opens the quest detail page.
  Future<void> _openHabitDetails(Habit habit) async {
    final habitIndex = _habits.indexOf(habit);
    if (habitIndex < 0) return;

    // Capture the ID so edits do not target a different habit.
    final habitId = _habitIds[habitIndex];

    final deletedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute<Habit>(
        builder: (context) => QuestDetailScreen(
          habit: habit,
          isCompleted: _completed[habitIndex],

          onCompletionChanged: (isComplete) {
            final currentIndex = _habitIds.indexOf(habitId);

            if (currentIndex >= 0) {
              _updateCompletion(currentIndex, isComplete);
            }
          },

          onHabitUpdated: (updatedHabit) {
            if (!mounted) return;

            final currentIndex = _habitIds.indexOf(habitId);
            if (currentIndex < 0) return;

            setState(() {
              _habits[currentIndex] = updatedHabit;
            });
          },
        ),
      ),
    );

    if (!mounted || deletedHabit == null) return;

    // Delete the correct habit even if it was edited.
    final deletedIndex = _habitIds.indexOf(habitId);
    if (deletedIndex < 0) return;

    setState(() {
      _habits.removeAt(deletedIndex);
      _completed.removeAt(deletedIndex);
      _habitIds.removeAt(deletedIndex);
    });

    _showActionSnackBar('Quest deleted');
  }

  // Adds a newly created habit.
  Future<void> _addHabit() async {
    final newHabit = await showDialog<Habit>(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );

    if (!mounted || newHabit == null) return;

    setState(() {
      _habits.add(newHabit);
      _completed.add(false);
      _habitIds.add('habit-${_nextHabitId++}');
    });

    _showActionSnackBar('Quest created successfully!');
  }

  // Awards XP and creates completion records.
  void _updateCompletion(int index, bool isComplete) {
    if (index < 0 || index >= _completed.length) {
      return;
    }

    // Do not process an unchanged completion state.
    if (_completed[index] == isComplete) {
      return;
    }

    final habit = _habits[index];
    final now = DateTime.now();
    final xpEarned = habit.xpReward > 0 ? habit.xpReward : _xpEngine.xpPerQuest;

    final completionId =
        '${_habitIds[index]}-${now.year}-${now.month}-${now.day}';

    setState(() {
      _completed[index] = isComplete;

      if (isComplete) {
        // Award XP only once per completion ID.
        final awarded = _xpEngine.awardQuest(completionId, xp: xpEarned);

        if (awarded) {
          _completionRecords.add(
            CompletionRecord(
              id: completionId,
              habitName: habit.name,
              completedAt: now,
              xpEarned: xpEarned,
            ),
          );
        }
      } else {
        // Undo XP if the quest is marked incomplete.
        final removed = _xpEngine.undoQuest(completionId);

        if (removed) {
          _completionRecords.removeWhere((record) => record.id == completionId);
        }
      }
    });
  }

  // Builds the side navigation drawer.
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

  // Shows confirmation messages to the user.
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
