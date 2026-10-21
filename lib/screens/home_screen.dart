import 'package:flutter/material.dart';

import '../widgets/section_heading.dart';

/// First UI entry screen for HabitQuest. Habit data will be connected later.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitQuest'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Your next small win starts here',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Build steady habits, one day at a time.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            color: colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Your habits will show up here.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add a habit'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeading(title: 'Your progress'),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.auto_awesome_outlined),
              title: Text('A fresh start'),
              subtitle: Text('Complete a habit to begin your journey.'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Rewards'),
        ],
        onDestinationSelected: (index) {
          // Add routes here as those screens are designed and implemented.
        },
      ),
    );
  }
}
