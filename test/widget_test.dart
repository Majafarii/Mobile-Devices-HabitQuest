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
        expect(find.text('Level 4'), findsOneWidget);
      } else if (index == 2) {
        expect(find.text('2 of 6 badges unlocked'), findsOneWidget);
        expect(find.text('Perfect Week'), findsOneWidget);
      } else if (index == 3) {
        expect(find.text('Alex Morgan'), findsOneWidget);
        expect(
          find.text(
            'Authentication and Firebase synchronization are not yet implemented.',
          ),
          findsOneWidget,
        );

        await tester.drag(find.byType(ListView).last, const Offset(0, -450));
        await tester.pumpAndSettle();
        final darkThemeTile = find.widgetWithText(SwitchListTile, 'Dark theme');
        await tester.tap(darkThemeTile);
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(darkThemeTile)).brightness,
          Brightness.dark,
        );

        await tester.tap(darkThemeTile);
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(darkThemeTile)).brightness,
          Brightness.light,
        );
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

  testWidgets('deleting quests confirms first and shows the empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    await tester.scrollUntilVisible(
      find.text('Drink Water'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Drink Water'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete Quest'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Quest'));
    await tester.pumpAndSettle();
    expect(find.text('Delete quest?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Drink Water'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Drink Water'), findsOneWidget);

    final habitNames = [
      'Drink Water',
      'Study 1 Hour',
      'Morning Workout',
      'Read 20 Minutes',
    ];

    for (final habitName in habitNames) {
      await tester.scrollUntilVisible(
        find.text(habitName),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(habitName));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Delete Quest'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Quest'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Quest deleted'), findsOneWidget);
    expect(find.text('No quests yet'), findsOneWidget);
    expect(
      find.text('Add a habit to start building your journey.'),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
