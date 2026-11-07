import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/user_account.dart';
import '../models/user_progress.dart';
import '../widgets/add_habit_dialog.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'quest_detail_screen.dart';

/// Owns the app's top-level tab selection and keeps navigation visible.
///
/// All quest and score data comes from the signed-in account's [progress];
/// [onProgressChanged] is called after every change so it can be saved.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.account,
    required this.progress,
    required this.onProgressChanged,
    required this.onSignOut,
    required this.onDarkModeChanged,
    required this.onTextScaleFactorChanged,
  });

  final UserAccount account;
  final UserProgress progress;
  final VoidCallback onProgressChanged;
  final VoidCallback onSignOut;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<double> onTextScaleFactorChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  UserProgress get _progress => widget.progress;
  List<Habit> get _habits => _progress.habits;
  List<bool> get _completed => _progress.completedToday;

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
              progress: _progress,
              habits: _habits,
              completed: _completed,
              onCompletionChanged: (index, isComplete) {
                _updateCompletion(index, isComplete);
                _showActionSnackBar(
                  isComplete ? 'Quest completed!' : 'Quest marked incomplete',
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
                        return _habits[habitIndex];
                      },
                      onHabitUpdated: (updatedHabit) {
                        if (!mounted || habitIndex < 0) return;
                        setState(() {
                          _habits[habitIndex] = updatedHabit;
                        });
                        widget.onProgressChanged();
                      },
                    ),
                  ),
                );
                if (!context.mounted || deletedHabit == null) return;
                if (habitIndex >= _habits.length) return;

                setState(() {
                  _progress.removeHabitAt(habitIndex);
                });
                widget.onProgressChanged();
                _showActionSnackBar('Quest deleted');
              },
            )
          : _selectedIndex == 1
          ? ProgressScreen(progress: _progress)
          : _selectedIndex == 2
          ? AchievementsScreen(progress: _progress)
          : ProfileScreen(
              account: widget.account,
              progress: _progress,
              isDarkMode: _progress.isDarkMode,
              demoNotificationsEnabled: _progress.notificationsEnabled,
              textScaleFactor: _progress.textScaleFactor,
              onDarkModeChanged: widget.onDarkModeChanged,
              onDemoNotificationsChanged: (isEnabled) {
                setState(() {
                  _progress.notificationsEnabled = isEnabled;
                });
                widget.onProgressChanged();
              },
              onTextScaleFactorChanged: widget.onTextScaleFactorChanged,
              onSignOut: _confirmSignOut,
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
                  _progress.addHabit(newHabit);
                });
                widget.onProgressChanged();
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
                        Text(
                          widget.account.displayName,
                          style: textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Level ${_progress.level} · ${_progress.totalXp} XP',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign out'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmSignOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          'Your progress is saved to ${widget.account.displayName}\'s account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true) widget.onSignOut();
  }

  void _updateCompletion(int index, bool isComplete) {
    if (index < 0 || index >= _completed.length) return;

    setState(() {
      _progress.setCompletion(index, isComplete, DateTime.now());
    });
    widget.onProgressChanged();
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
