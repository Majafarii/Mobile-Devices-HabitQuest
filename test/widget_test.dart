import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/main.dart';

void main() {
  testWidgets('HabitQuest opens on Home and switches between all tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    expect(
      find.descendant(of: find.byType(Center), matching: find.text('Home')),
      findsOneWidget,
    );
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

      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.text(tabTitles[index]),
        ),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });
}
