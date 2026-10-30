import 'package:flutter/material.dart';

/// Profile and preference controls populated with demo account details.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _demoNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Profile', style: textTheme.displayLarge),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 38,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex Morgan', style: textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text('DEMO USER', style: textTheme.labelSmall),
                        const SizedBox(height: 7),
                        Text(
                          'Level 4 - Sample level',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email (demo)'),
                  subtitle: const Text('alex.morgan@example.com'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: const Text('Sync status'),
                  subtitle: const Text('Not connected'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Authentication and Firebase synchronization are not yet implemented.',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Preferences', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text(
                    'Demo setting only; notification scheduling is not connected.',
                  ),
                  value: _demoNotificationsEnabled,
                  onChanged: (isEnabled) {
                    setState(() {
                      _demoNotificationsEnabled = isEnabled;
                    });
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark theme'),
                  subtitle: Text(
                    widget.isDarkMode
                        ? 'Dark appearance is on'
                        : 'Use dark appearance',
                  ),
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('About HabitQuest', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('HabitQuest'),
              subtitle: const Text(
                'A simple way to build healthy habits, one quest at a time.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
