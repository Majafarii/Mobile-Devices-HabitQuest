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
  double _textScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitQuest',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(_textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AppShell(
        isDarkMode: _isDarkMode,
        textScaleFactor: _textScaleFactor,
        onDarkModeChanged: (isDarkMode) {
          setState(() {
            _isDarkMode = isDarkMode;
          });
        },
        onTextScaleFactorChanged: (textScaleFactor) {
          setState(() {
            _textScaleFactor = textScaleFactor;
          });
        },
      ),
    );
  }
}
