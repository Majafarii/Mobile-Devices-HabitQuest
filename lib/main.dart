import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HabitQuestApp());
}

/// The app entry point. Keep app-wide setup and navigation here.
class HabitQuestApp extends StatefulWidget {
  const HabitQuestApp({super.key});

  @override
  State<HabitQuestApp> createState() => _HabitQuestAppState();
}

class _HabitQuestAppState extends State<HabitQuestApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitQuest',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppShell(
        isDarkMode: _isDarkMode,
        onDarkModeChanged: (isDarkMode) {
          setState(() {
            _isDarkMode = isDarkMode;
          });
        },
      ),
    );
  }
}
