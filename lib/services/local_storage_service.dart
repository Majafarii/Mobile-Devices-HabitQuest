import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

// Service responsible for persisting habits and quest data locally.
class LocalStorageService {
  static const String _habitsKey = 'habitquest_habits';
  static const String _statsKey = 'habitquest_user_stats';

  // Default starter habits to seed on first launch.
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

  // Fetch all habits stored locally. Seeds starter data on first launch.
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

  /// Save habit list to device storage.
  Future<bool> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      habits.map((h) => h.toMap()).toList(),
    );
    return prefs.setString(_habitsKey, encodedList);
  }

  // Add a single new habit.
  Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  // Delete a habit by name or id.
  Future<void> deleteHabit(String habitIdentifier) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => (h.id ?? h.name) == habitIdentifier);
    await saveHabits(habits);
  }
}
