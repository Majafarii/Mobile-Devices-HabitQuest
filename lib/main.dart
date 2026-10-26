import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HabitQuestApp());
}

/// The app entry point. Keep app-wide setup and navigation here.
class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitQuest',
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
