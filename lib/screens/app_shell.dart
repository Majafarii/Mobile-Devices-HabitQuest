import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/user_account.dart';
import '../models/user_progress.dart';
import '../services/achievement_engine.dart';
import '../services/progress_tracker.dart';
import '../services/xp_engine.dart';
import '../widgets/add_habit_dialog.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'quest_detail_screen.dart';

/// Main navigation for the signed-in account and its persisted progress.
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
  final XpEngine _xpEngine = XpEngine();

  UserProgress get _progress => widget.progress;
  List<Habit> get _habits => _progress.habits;
  List<bool> get _completed => _progress.completedToday;

  List<CompletionRecord> get _completionRecords => [
    for (final record in _progress.completionHistory)
      CompletionRecord(
        id: record.id,
        habitName: record.habitName,
        completedAt: record.completedAt,
        xpEarned: record.xpEarned,
      ),
  ];

  static const _tabs = [
    _TabInfo(title: 'Home', icon: Icons.home_outlined),
    _TabInfo(title: 'Progress', icon: Icons.insights_outlined),
    _TabInfo(title: 'Achievements', icon: Icons.emoji_events_outlined),
    _TabInfo(title: 'Profile', icon: Icons.person_outline),
  ];

  @override
  void initState() {
    super.initState();

    var idsChanged = false;
    final usedIds = <String>{};
    for (var index = 0; index < _habits.length; index++) {
      final habit = _habits[index];
      final id = habit.id;
      if (id == null || id.isEmpty || !usedIds.add(id)) {
        final generatedId = _newHabitId(index);
        _habits[index] = habit.copyWith(id: generatedId);
        usedIds.add(generatedId);
        idsChanged = true;
      }
    }

    for (final completion in _progress.completionHistory) {
      _xpEngine.awardQuest(completion.id, xp: completion.xpEarned);
    }
    if (idsChanged) widget.onProgressChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0 ? null : const Text('HabitQuest'),
      ),
      drawer: _buildDrawer(context),
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
          setState(() => _selectedIndex = index);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.title),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          progress: _progress,
          habits: _habits,
          completed: _completed,
          xpEngine: _xpEngine,
          onCompletionChanged: _onHomeCompletionChanged,
          onHabitTap: _openHabitDetails,
        );
      case 1:
        return ProgressScreen(
          progress: _progress,
          xpEngine: _xpEngine,
          records: _completionRecords,
        );
      case 2:
        final achievements = AchievementProgress(
          totalCompletions: _progress.totalCompletions,
          level: _xpEngine.level,
          longestStreak: _progress.longestStreak,
          hasPerfectWeek:
              _progress.habits.isNotEmpty &&
              _progress.habits.every(
                (habit) => habit.weeklyCompletions.every((day) => day),
              ),
        );
        return AchievementsScreen(progress: achievements);
      case 3:
        return ProfileScreen(
          account: widget.account,
          progress: _progress,
          isDarkMode: _progress.isDarkMode,
          demoNotificationsEnabled: _progress.notificationsEnabled,
          textScaleFactor: _progress.textScaleFactor,
          onDarkModeChanged: widget.onDarkModeChanged,
          onDemoNotificationsChanged: (enabled) {
            setState(() => _progress.notificationsEnabled = enabled);
            widget.onProgressChanged();
          },
          onTextScaleFactorChanged: widget.onTextScaleFactorChanged,
          onSignOut: _confirmSignOut,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onHomeCompletionChanged(int index, bool isComplete) {
    if (index < 0 || index >= _habits.length) return;
    final before = _xpEngine.totalXp;
    _updateCompletion(index, isComplete);
    final change = _xpEngine.totalXp - before;

    if (change > 0) {
      _showActionSnackBar('Quest completed! +$change XP');
    } else if (change < 0) {
      _showActionSnackBar('Quest marked incomplete. $change XP');
    } else {
      _showActionSnackBar(
        isComplete ? 'Quest already rewarded today' : 'Quest marked incomplete',
      );
    }
  }

  Future<void> _openHabitDetails(Habit habit) async {
    final initialIndex = _habits.indexOf(habit);
    if (initialIndex < 0) return;
    final habitId = _habits[initialIndex].id;
    if (habitId == null) return;

    final deletedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute<Habit>(
        builder: (context) => QuestDetailScreen(
          habit: habit,
          isCompleted: _completed[initialIndex],
          onCompletionChanged: (isComplete) {
            final index = _indexOfHabitId(habitId);
            if (index < 0) return habit;
            _updateCompletion(index, isComplete);
            return _habits[index];
          },
          onHabitUpdated: (updatedHabit) {
            final index = _indexOfHabitId(habitId);
            if (!mounted || index < 0) return;
            setState(() => _habits[index] = updatedHabit);
            widget.onProgressChanged();
          },
        ),
      ),
    );

    if (!mounted || deletedHabit == null) return;
    final deletedIndex = _indexOfHabitId(habitId);
    if (deletedIndex < 0) return;

    setState(() => _progress.removeHabitAt(deletedIndex));
    widget.onProgressChanged();
    _showActionSnackBar('Quest deleted');
  }

  Future<void> _addHabit() async {
    final newHabit = await showDialog<Habit>(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );
    if (!mounted || newHabit == null) return;

    setState(() {
      _progress.addHabit(newHabit.copyWith(id: _newHabitId(_habits.length)));
    });
    widget.onProgressChanged();
    _showActionSnackBar('Quest created successfully!');
  }

  void _updateCompletion(int index, bool isComplete) {
    if (index < 0 || index >= _habits.length || index >= _completed.length) {
      return;
    }
    if (_completed[index] == isComplete) return;

    final habit = _habits[index];
    final now = DateTime.now();
    final habitId = habit.id ?? 'habit-$index';
    final completionId = '$habitId-${now.year}-${now.month}-${now.day}';
    final reward = habit.xpReward > 0 ? habit.xpReward : _xpEngine.xpPerQuest;

    setState(() {
      _progress.setCompletion(
        index,
        isComplete,
        now,
        xpEarned: reward,
        completionId: completionId,
      );
      if (isComplete) {
        _xpEngine.awardQuest(completionId, xp: reward);
      } else {
        _xpEngine.undoQuest(completionId);
      }
    });
    widget.onProgressChanged();
  }

  int _indexOfHabitId(String id) =>
      _habits.indexWhere((habit) => habit.id == id);

  String _newHabitId(int index) =>
      '${widget.account.username}-${DateTime.now().microsecondsSinceEpoch}-$index';

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
                          'Level ${_xpEngine.level} · ${_xpEngine.totalXp} XP',
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
                        setState(() => _selectedIndex = index);
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
                  setState(() => _selectedIndex = 3);
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
