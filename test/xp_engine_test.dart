import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/services/xp_engine.dart';

void main() {
  group('XP Engine', () {
    test('starts at Level 1 with zero XP', () {
      final engine = XpEngine();

      expect(engine.totalXp, 0);
      expect(engine.level, 1);
      expect(engine.levelProgress, 0);
      expect(engine.xpRemaining, 100);
    });

    test('awards XP for completed quests', () {
      final engine = XpEngine();

      engine.awardQuest('habit-1-2026-11-04');
      engine.awardQuest('habit-2-2026-11-04');

      expect(engine.totalXp, 50);
      expect(engine.level, 1);
      expect(engine.levelProgress, 0.5);
    });

    test('prevents duplicate XP rewards', () {
      final engine = XpEngine();

      expect(engine.awardQuest('quest-1'), true);
      expect(engine.awardQuest('quest-1'), false);

      expect(engine.totalXp, 25);
    });

    test('levels up when XP threshold is reached', () {
      final engine = XpEngine();

      for (var i = 0; i < 12; i++) {
        engine.awardQuest('quest-$i');
      }

      expect(engine.totalXp, 300);
      expect(engine.level, 3);
      expect(engine.levelProgress, 0);
    });

    test('reverses XP when completion is undone', () {
      final engine = XpEngine();

      engine.awardQuest('quest-1');
      engine.undoQuest('quest-1');

      expect(engine.totalXp, 0);
      expect(engine.hasAwarded('quest-1'), false);
    });

    test('rejects invalid rewards', () {
      final engine = XpEngine();

      expect(() => engine.awardQuest('quest-1', xp: -10), throwsArgumentError);
    });
  });
}
