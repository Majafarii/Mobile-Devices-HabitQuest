import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitquest/models/habit.dart';
import 'package:habitquest/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storageService;

  setUp(() {
    // Reset SharedPreferences to an empty mock state before each test
    SharedPreferences.setMockInitialValues({});
    storageService = LocalStorageService();
  });

  group('LocalStorageService Tests', () {
    test(
      'loadHabits seeds default habits when storage is initially empty',
      () async {
        final habits = await storageService.loadHabits();
        expect(habits.length, equals(2));
        expect(habits.first.name, equals('Morning Hydration'));
      },
    );

    test('addHabit adds and persists a new habit', () async {
      const newHabit = Habit(
        id: 'habit_test',
        name: 'Workout 30 mins',
        category: 'Fitness',
        streak: 1,
        xpReward: 75,
      );

      await storageService.addHabit(newHabit);
      final habits = await storageService.loadHabits();

      expect(habits.length, equals(3));
      expect(habits.any((h) => h.name == 'Workout 30 mins'), isTrue);
    });

    test('deleteHabit removes a habit by identifier', () async {
      await storageService.deleteHabit('habit_1');
      final habits = await storageService.loadHabits();

      expect(habits.length, equals(1));
      expect(habits.first.name, equals('Read 15 Pages'));
    });

    test('toggleHabitDay updates completion, streak, and awards XP', () async {
      // Toggle Monday (index 0) on default habit_1 (50 XP reward)
      final updated = await storageService.toggleHabitDay('habit_1', 0);
      expect(updated, isNotNull);
      expect(updated!.weeklyCompletions[0], isTrue);
      expect(updated.streak, equals(4)); // 3 default + 1

      final stats = await storageService.loadUserStats();
      expect(stats.currentXp, equals(1300)); // 1250 default + 50
    });

    test(
      'addXp correctly levels up the user when threshold is passed',
      () async {
        // Starting stats: level 4, currentXp: 1250, threshold: 1800
        // Need 550 XP to hit level 5
        final updatedStats = await storageService.addXp(600);

        expect(updatedStats.level, equals(5));
        expect(updatedStats.currentXp, equals(50)); // 1850 - 1800
      },
    );
  });
}
