import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../models/user_stats.dart';

// Service responsible for persisting habits, streaks, and XP locally.
class LocalStorageService {
  static const String _habitsKey = 'habitquest_habits';
  static const String _statsKey = 'habitquest_user_stats';

  static const List<Habit> _defaultHabits = [
    Habit(
      id: 'habit_1',
      name: 'Morning Hydration',
      category: 'Health',
      description: 'Drink 500ml water right after waking up',
      frequency: 'Daily',
      reminderTime: '08:00 AM',
      streak: 3,
      xpReward: 50,
    ),
    Habit(
      id: 'habit_2',
      name: 'Read 15 Pages',
      category: 'Learning',
      description: 'Software design & algorithms book',
      frequency: 'Daily',
      reminderTime: '09:30 PM',
      streak: 5,
      xpReward: 100,
    ),
  ];

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);

    if (habitsJson == null) {
      await saveHabits(_defaultHabits);
      return _defaultHabits;
    }

    final List<dynamic> decodedList = json.decode(habitsJson) as List<dynamic>;
    return decodedList
        .map((item) => Habit.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      habits.map((h) => h.toMap()).toList(),
    );
    return prefs.setString(_habitsKey, encodedList);
  }

  Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> deleteHabit(String habitIdentifier) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => (h.id ?? h.name) == habitIdentifier);
    await saveHabits(habits);
  }

  // Load user level, XP, and streak progress. Seeds baseline stats if null.
  Future<UserStats> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_statsKey);

    if (statsJson == null) {
      const defaultStats = UserStats(
        level: 4,
        currentXp: 1250,
        xpToNextLevel: 1800,
        totalStreak: 5,
      );
      await saveUserStats(defaultStats);
      return defaultStats;
    }

    return UserStats.fromJson(statsJson);
  }

  // Persist updated user XP, level, and streaks.
  Future<bool> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_statsKey, stats.toJson());
  }

  // Add XP, calculate level progression, and persist the updated stats.
  Future<UserStats> addXp(int xpEarned) async {
    var stats = await loadUserStats();
    int newXp = stats.currentXp + xpEarned;
    int currentLevel = stats.level;
    int nextLevelGoal = stats.xpToNextLevel;

    while (newXp >= nextLevelGoal) {
      newXp -= nextLevelGoal;
      currentLevel += 1;
      nextLevelGoal = (nextLevelGoal * 1.25).toInt();
    }

    final updatedStats = stats.copyWith(
      level: currentLevel,
      currentXp: newXp,
      xpToNextLevel: nextLevelGoal,
    );

    await saveUserStats(updatedStats);
    return updatedStats;
  }
}
