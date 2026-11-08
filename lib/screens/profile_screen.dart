import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../models/user_progress.dart';

/// Profile, stats and preference controls for the signed-in account.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.account,
    required this.progress,
    required this.isDarkMode,
    required this.demoNotificationsEnabled,
    required this.textScaleFactor,
    required this.onDarkModeChanged,
    required this.onDemoNotificationsChanged,
    required this.onTextScaleFactorChanged,
    required this.onSignOut,
  });

  final UserAccount account;
  final UserProgress progress;
  final VoidCallback onSignOut;
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
                        Text(account.displayName, style: textTheme.titleLarge),
                        const SizedBox(height: 3),
                        Text(
                          '@${account.username}',
                          style: textTheme.labelSmall,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Level ${progress.level} · ${progress.totalXp} XP',
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
                  title: const Text('Email'),
                  subtitle: Text(
                    account.email.isEmpty ? 'Not provided' : account.email,
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: const Text('Quests completed'),
                  subtitle: Text(
                    '${progress.totalCompletions} total · '
                    'longest streak ${progress.longestStreak} days',
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.phone_android_outlined),
                  title: const Text('Storage'),
                  subtitle: const Text('Saved on this device'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: colors.error),
                  title: Text(
                    'Sign out',
                    style: TextStyle(color: colors.error),
                  ),
                  onTap: onSignOut,
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
