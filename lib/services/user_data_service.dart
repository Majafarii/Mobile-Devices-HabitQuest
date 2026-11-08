import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

/// Loads and saves each account's [UserProgress] under its own storage key,
/// so one user's quests and score never mix with another's.
class UserDataService {
  UserDataService(this._prefs);

  final SharedPreferences _prefs;

  static Future<UserDataService> create() async =>
      UserDataService(await SharedPreferences.getInstance());

  static String _keyFor(String username) => 'user.$username.progress';

  /// Returns the saved progress for [username], or fresh starter data for a
  /// new account. Applies any daily/weekly reset that is due.
  Future<UserProgress> load(String username, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    final raw = _prefs.getString(_keyFor(username));
    if (raw == null) {
      final progress = UserProgress.newAccount(current);
      await save(username, progress);
      return progress;
    }

    final progress = UserProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    if (progress.rollOver(current)) await save(username, progress);
    return progress;
  }

  Future<void> save(String username, UserProgress progress) {
    return _prefs.setString(_keyFor(username), jsonEncode(progress.toJson()));
  }
}
