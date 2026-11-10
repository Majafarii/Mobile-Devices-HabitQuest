import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/main.dart';
import 'package:habitquest/models/user_progress.dart';
import 'package:habitquest/services/auth_service.dart';
import 'package:habitquest/services/user_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.dart' show signUpThroughUi, usePhoneViewport;

Future<void> signInThroughUi(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('auth.username')), username);
  await tester.enterText(find.byKey(const Key('auth.password')), password);
  await tester.tap(find.byKey(const Key('auth.submit')));
  await tester.pumpAndSettle();
}

Future<void> signOutThroughDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Sign out'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService', () {
    test('pre-created demo account signs in through regular login', () async {
      final auth = await AuthService.create();

      final account = await auth.signIn(
        username: AuthService.demoUsername,
        password: AuthService.demoPassword,
      );

      expect(account.displayName, 'Demo Adventurer');
      expect(auth.restoreSession()?.username, AuthService.demoUsername);
    });

    test(
      'restores demo credentials if a conflicting demo account exists',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await AuthService(prefs).signUp(
          username: AuthService.demoUsername,
          displayName: 'Other User',
          email: '',
          password: 'different-password',
        );

        final auth = await AuthService.create();
        final account = await auth.signIn(
          username: AuthService.demoUsername,
          password: AuthService.demoPassword,
        );

        expect(account.displayName, 'Demo Adventurer');
      },
    );

    test(
      'signs up, rejects duplicates, and never stores the password',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final auth = AuthService(prefs);

        final account = await auth.signUp(
          username: 'Alice',
          displayName: 'Alice A',
          email: 'alice@example.com',
          password: 'wonderland',
        );
        expect(account.username, 'alice');
        expect(account.passwordHash, isNot('wonderland'));
        for (final key in prefs.getKeys()) {
          expect('${prefs.get(key)}', isNot(contains('wonderland')));
        }

        expect(
          () => auth.signUp(
            username: 'alice',
            displayName: '',
            email: '',
            password: 'another1',
          ),
          throwsA(isA<AuthException>()),
        );
      },
    );

    test('signs in with the correct password only', () async {
      final auth = AuthService(await SharedPreferences.getInstance());
      await auth.signUp(
        username: 'bob',
        displayName: 'Bob',
        email: '',
        password: 'builder1',
      );

      final account = await auth.signIn(username: 'BOB', password: 'builder1');
      expect(account.displayName, 'Bob');
      expect(
        () => auth.signIn(username: 'bob', password: 'wrong-pass'),
        throwsA(isA<AuthException>()),
      );
      expect(
        () => auth.signIn(username: 'nobody', password: 'builder1'),
        throwsA(isA<AuthException>()),
      );
    });

    test('remember me controls whether the session is restored', () async {
      final prefs = await SharedPreferences.getInstance();
      final auth = AuthService(prefs);
      await auth.signUp(
        username: 'carol',
        displayName: 'Carol',
        email: '',
        password: 'password1',
        rememberMe: false,
      );
      expect(AuthService(prefs).restoreSession(), isNull);
      expect(AuthService(prefs).lastUsername, 'carol');

      await auth.signIn(username: 'carol', password: 'password1');
      expect(AuthService(prefs).restoreSession()?.username, 'carol');

      await auth.signOut();
      expect(AuthService(prefs).restoreSession(), isNull);
    });
  });

  group('UserProgress', () {
    test('completions award XP and update streaks', () {
      final now = DateTime(2026, 11, 4); // Wednesday
      final progress = UserProgress.newAccount(now);

      progress.setCompletion(0, true, now);
      expect(progress.totalXp, UserProgress.xpPerCompletion);
      expect(progress.totalCompletions, 1);
      expect(progress.habits[0].streak, 1);
      expect(progress.weeklyXp[2], UserProgress.xpPerCompletion);

      progress.setCompletion(0, false, now);
      expect(progress.totalXp, 0);
      expect(progress.habits[0].streak, 0);
    });

    test('a new day keeps streaks for completed quests and breaks others', () {
      final day1 = DateTime(2026, 11, 4);
      final progress = UserProgress.newAccount(day1)
        ..setCompletion(0, true, day1);

      expect(progress.rollOver(DateTime(2026, 11, 5, 9)), isTrue);
      expect(progress.habits[0].streak, 1);
      expect(progress.completedToday[0], isFalse);

      // Skip a day: every streak breaks.
      expect(progress.rollOver(DateTime(2026, 11, 7)), isTrue);
      expect(progress.habits[0].streak, 0);
    });

    test('a new week clears weekly stats but keeps total XP', () {
      final sunday = DateTime(2026, 11, 8);
      final progress = UserProgress.newAccount(sunday)
        ..setCompletion(0, true, sunday);
      progress.rollOver(DateTime(2026, 11, 9)); // Monday
      expect(progress.weeklyXp, everyElement(0));
      expect(progress.habits[0].weeklyCompletions, everyElement(isFalse));
      expect(progress.totalXp, UserProgress.xpPerCompletion);
    });
  });

  test('UserDataService keeps each account separate', () async {
    final service = UserDataService(await SharedPreferences.getInstance());
    final now = DateTime.now();

    final alice = await service.load('alice', now: now);
    alice.setCompletion(0, true, now);
    alice.isDarkMode = true;
    await service.save('alice', alice);

    final bob = await service.load('bob', now: now);
    expect(bob.totalXp, 0);
    expect(bob.isDarkMode, isFalse);

    final aliceAgain = await service.load('alice', now: now);
    expect(aliceAgain.totalXp, UserProgress.xpPerCompletion);
    expect(aliceAgain.completedToday[0], isTrue);
    expect(aliceAgain.isDarkMode, isTrue);
  });

  testWidgets('each user sees only their own quests and score', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const HabitQuestApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back! Sign in to continue.'), findsOneWidget);

    // Alice completes a quest.
    await signUpThroughUi(
      tester,
      username: 'alice',
      displayName: 'Alice',
      password: 'wonderland',
    );
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('25 total XP'), findsOneWidget);
    await signOutThroughDrawer(tester);

    // Bob starts fresh.
    await signUpThroughUi(
      tester,
      username: 'bob',
      displayName: 'Bob',
      password: 'builder1',
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isFalse);
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('0 total XP'), findsOneWidget);
    await signOutThroughDrawer(tester);

    // Wrong password is rejected.
    await signInThroughUi(tester, username: 'alice', password: 'nope-nope');
    expect(find.text('Incorrect username or password.'), findsOneWidget);

    // Alice's progress is still there.
    await signInThroughUi(tester, username: 'alice', password: 'wonderland');
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('25 total XP'), findsOneWidget);
  });

  testWidgets('a remembered user is signed in automatically', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const HabitQuestApp());
    await tester.pumpAndSettle();
    await signUpThroughUi(
      tester,
      username: 'dana',
      displayName: 'Dana',
      password: 'password1',
    );

    // Simulate an app restart.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const HabitQuestApp());
    await tester.pumpAndSettle();
    expect(find.text("Today's Quests"), findsOneWidget);
  });

  testWidgets('demo account can be logged into without signing up', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(const HabitQuestApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back! Sign in to continue.'), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    await signInThroughUi(
      tester,
      username: AuthService.demoUsername,
      password: AuthService.demoPassword,
    );

    expect(find.text("Today's Quests"), findsOneWidget);
    expect(find.byKey(const Key('auth.demo')), findsNothing);
  });
}
