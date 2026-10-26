import 'package:flutter/material.dart';

/// Owns the app's top-level tab selection and keeps navigation visible.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabInfo(title: 'Home', icon: Icons.home_outlined),
    _TabInfo(title: 'Progress', icon: Icons.insights_outlined),
    _TabInfo(title: 'Achievements', icon: Icons.emoji_events_outlined),
    _TabInfo(title: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTab = _tabs[_selectedIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('HabitQuest')),
      body: Center(
        child: Text(
          selectedTab.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.title,
            ),
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
