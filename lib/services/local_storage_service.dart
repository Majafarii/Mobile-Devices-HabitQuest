import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

// Service responsible for local persistence and seed data initialization.
class LocalStorageService {
  static const String _habitsKey = 'habitquest_habits';
  static const String _statsKey = 'habitquest_user_stats';

  /// Default starter habits to seed on first launch.
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

  // Initialize and seed default habits if storage is currently empty.
  Future<void> initDefaultsIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_habitsKey)) {
      final String encodedList = json.encode(
        _defaultHabits.map((h) => h.toMap()).toList(),
      );
      await prefs.setString(_habitsKey, encodedList);
    }
  }
}
