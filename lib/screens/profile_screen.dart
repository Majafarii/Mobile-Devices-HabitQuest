import 'package:flutter/material.dart';

/// Profile and preference controls populated with demo account details.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.demoNotificationsEnabled,
    required this.textScaleFactor,
    required this.onDarkModeChanged,
    required this.onDemoNotificationsChanged,
    required this.onTextScaleFactorChanged,
  });

  final bool isDarkMode;
  final bool demoNotificationsEnabled;
  final double textScaleFactor;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onDemoNotificationsChanged;
  final ValueChanged<double> onTextScaleFactorChanged;

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
                  value: demoNotificationsEnabled,
                  onChanged: onDemoNotificationsChanged,
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark theme'),
                  subtitle: Text(
                    isDarkMode
                        ? 'Dark appearance is on'
                        : 'Use dark appearance',
                  ),
                  value: isDarkMode,
                  onChanged: onDarkModeChanged,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.text_fields_rounded),
                  title: const Text('Text size'),
                  subtitle: Text(
                    textScaleFactor < 1
                        ? 'Small'
                        : textScaleFactor > 1
                        ? 'Large'
                        : 'Default',
                  ),
                  trailing: DropdownButton<double>(
                    value: textScaleFactor,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0.9, child: Text('Small')),
                      DropdownMenuItem(value: 1.0, child: Text('Default')),
                      DropdownMenuItem(value: 1.2, child: Text('Large')),
                    ],
                    onChanged: (textScaleFactor) {
                      if (textScaleFactor != null) {
                        onTextScaleFactorChanged(textScaleFactor);
                      }
                    },
                  ),
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
