import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/main.dart';

void main() {
  testWidgets('HabitQuest opens on Home and switches between all tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    expect(find.text('HabitQuest'), findsWidgets);
    expect(find.text("Today's Quests"), findsOneWidget);
    expect(find.text('Drink Water'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    final tabIcons = [
      Icons.home_outlined,
      Icons.insights_outlined,
      Icons.emoji_events_outlined,
      Icons.person_outline,
    ];
    final tabTitles = ['Home', 'Progress', 'Achievements', 'Profile'];

    for (var index = 0; index < tabIcons.length; index++) {
      await tester.tap(find.byIcon(tabIcons[index]));
      await tester.pumpAndSettle();

      if (index == 0) {
        expect(find.text("Today's Quests"), findsOneWidget);
        expect(find.text('Drink Water'), findsOneWidget);
      } else if (index == 1) {
        expect(find.text('1,250 total XP'), findsOneWidget);
        expect(find.text('Recent Completions'), findsOneWidget);
      } else if (index == 2) {
        expect(find.text('2 of 6 badges unlocked'), findsOneWidget);
        expect(find.text('Perfect Week'), findsOneWidget);
      } else {
        expect(
          find.descendant(
            of: find.byType(Center),
            matching: find.text(tabTitles[index]),
          ),
          findsOneWidget,
        );
      }
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });
}
