import 'package:flutter/material.dart';

import 'models/user_account.dart';
import 'models/user_progress.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HabitQuestApp());
}

/// The app entry point. Shows sign-in until an account is active, then the
/// main app populated with that account's own saved data.
class HabitQuestApp extends StatefulWidget {
  const HabitQuestApp({super.key});

  @override
  State<HabitQuestApp> createState() => _HabitQuestAppState();
}

class _HabitQuestAppState extends State<HabitQuestApp> {
  AuthService? _authService;
  UserDataService? _dataService;
  UserAccount? _account;
  UserProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authService = await AuthService.create();
    final dataService = await UserDataService.create();
    final account = authService.restoreSession();
    final progress = account == null
        ? null
        : await dataService.load(account.username);
    if (!mounted) return;
    setState(() {
      _authService = authService;
      _dataService = dataService;
      _account = account;
      _progress = progress;
      _isLoading = false;
    });
  }

  Future<void> _handleSignedIn(UserAccount account) async {
    final progress = await _dataService!.load(account.username);
    if (!mounted) return;
    setState(() {
      _account = account;
      _progress = progress;
    });
  }

  Future<void> _handleSignOut() async {
    await _authService!.signOut();
    if (!mounted) return;
    setState(() {
      _account = null;
      _progress = null;
    });
  }

  void _saveProgress() {
    final account = _account;
    final progress = _progress;
    if (account == null || progress == null) return;
    _dataService!.save(account.username, progress);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final isDarkMode = progress?.isDarkMode ?? false;
    final textScaleFactor = progress?.textScaleFactor ?? 1.0;

    return MaterialApp(
      title: 'HabitQuest',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final account = _account;
    final progress = _progress;
    if (account == null || progress == null) {
      return AuthScreen(
        authService: _authService!,
        onSignedIn: _handleSignedIn,
      );
    }

    return AppShell(
      // A new key per account guarantees no state carries over between users.
      key: ValueKey(account.username),
      account: account,
      progress: progress,
      onProgressChanged: _saveProgress,
      onSignOut: _handleSignOut,
      onDarkModeChanged: (isDarkMode) {
        setState(() => progress.isDarkMode = isDarkMode);
        _saveProgress();
      },
      onTextScaleFactorChanged: (textScaleFactor) {
        setState(() => progress.textScaleFactor = textScaleFactor);
        _saveProgress();
      },
    );
  }
}
