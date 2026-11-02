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

  testWidgets('drawer and bottom navigation share the selected destination', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    final destinations = ['Home', 'Progress', 'Achievements', 'Profile'];
    final contentChecks = [
      "Today's Quests",
      '1,250 total XP',
      '2 of 6 badges unlocked',
      'Alex Morgan',
    ];

    for (var index = 0; index < destinations.length; index++) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, destinations[index]));
      await tester.pumpAndSettle();

      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        index,
      );
      expect(find.text(contentChecks[index]), findsOneWidget);
    }

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Achievements'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Achievements'),
      ).selected,
      isTrue,
    );
  });

  testWidgets('drawer Settings opens Profile and applies app-wide preferences', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(
      find.text(
        'Demo setting only; notification scheduling is not connected.',
      ),
      findsOneWidget,
    );
    final notificationsTile = find.widgetWithText(
      SwitchListTile,
      'Notifications',
    );
    await tester.ensureVisible(notificationsTile);
    await tester.pumpAndSettle();
    await tester.tap(notificationsTile);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(notificationsTile).value, isTrue);

    await tester.ensureVisible(find.text('Text size'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<double>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large').last);
    await tester.pumpAndSettle();

    final profileText = find.text('Alex Morgan');
    expect(
      MediaQuery.textScalerOf(tester.element(profileText)).scale(10),
      12,
    );
    expect(tester.takeException(), isNull);

    final darkThemeTile = find.widgetWithText(SwitchListTile, 'Dark theme');
    await tester.ensureVisible(darkThemeTile);
    await tester.pumpAndSettle();
    await tester.tap(darkThemeTile);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Alex Morgan'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text("Today's Quests"), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text("Today's Quests"))).brightness,
      Brightness.dark,
    );
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.text("Today's Quests")),
      ).scale(10),
      12,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Profile'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Notifications'),
      ).value,
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Habit'));
    await tester.pumpAndSettle();
    expect(find.text('Add a Habit'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Add a Habit'))).brightness,
      Brightness.dark,
    );
    final dialogTextScale = MediaQuery.textScalerOf(
      tester.element(find.text('Habit name')),
    ).scale(10);
    expect(dialogTextScale, 12);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('quest completion toggles independently and persists across tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    final firstCheckbox = find.byType(Checkbox).at(0);
    final secondCheckbox = find.byType(Checkbox).at(1);

    expect(tester.widget<Checkbox>(firstCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(secondCheckbox).value, isFalse);

    await tester.ensureVisible(firstCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(firstCheckbox).value, isTrue);
    expect(tester.widget<Checkbox>(secondCheckbox).value, isFalse);
    expect(find.text('Quest completed!'), findsOneWidget);

    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(firstCheckbox).value, isFalse);
    expect(find.text('Quest marked incomplete'), findsOneWidget);

    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Checkbox>(find.byType(Checkbox).at(0)).value,
      isTrue,
    );
    expect(
      tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value,
      isFalse,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('quest completion stays in sync between Home and details', (
    tester,
  ) async {
    await tester.pumpWidget(const HabitQuestApp());

    final homeCheckbox = find.byType(Checkbox).at(0);
    await tester.ensureVisible(homeCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(homeCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(homeCheckbox).value, isTrue);

    await tester.ensureVisible(find.text('Drink Water'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drink Water'));
    await tester.pumpAndSettle();

    final detailCheckbox = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(detailCheckbox).value, isTrue);
    await tester.tap(detailCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(detailCheckbox).value, isFalse);
    expect(find.text('Quest marked incomplete'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(homeCheckbox).value, isFalse);
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
