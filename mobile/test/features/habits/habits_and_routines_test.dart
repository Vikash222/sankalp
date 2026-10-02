import 'package:arclife/core/storage/token_storage.dart';
import 'package:arclife/core/theme/sankalp_theme.dart';
import 'package:arclife/core/theme/theme_notifier.dart';
import 'package:arclife/features/gamification/presentation/providers/friends_league_notifier.dart';
import 'package:arclife/features/gamification/presentation/providers/gamification_notifier.dart';
import 'package:arclife/features/habits/domain/entities/habit_model.dart';
import 'package:arclife/features/habits/presentation/providers/habits_notifier.dart';
import 'package:arclife/features/habits/presentation/screens/habit_calendar_screen.dart';
import 'package:arclife/features/habits/presentation/screens/routine_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HabitsNotifier & Habit Model Tests', () {
    test('Adds, edits, and completes custom habits with streak calculation', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );

      final notifier = container.read(habitsNotifierProvider.notifier);
      final initialCount = container.read(habitsNotifierProvider).activeHabits.length;

      // Add a custom habit
      await notifier.addHabit(
        title: 'Stoic Evening Reading',
        description: 'Read Marcus Aurelius Meditations',
        category: HabitCategory.mindset,
        timeOfDay: HabitTimeOfDay.evening,
        xpReward: 30,
      );

      final stateAfterAdd = container.read(habitsNotifierProvider);
      expect(stateAfterAdd.activeHabits.length, initialCount + 1);

      final addedHabit = stateAfterAdd.activeHabits.firstWhere((h) => h.title == 'Stoic Evening Reading');
      expect(addedHabit.category, HabitCategory.mindset);
      expect(addedHabit.xpReward, 30);
      expect(addedHabit.currentStreak, 0);

      // Edit the habit
      await notifier.editHabit(
        id: addedHabit.id,
        title: 'Stoic Evening Reading & Journaling',
        category: HabitCategory.mindset,
        timeOfDay: HabitTimeOfDay.evening,
        xpReward: 35,
      );

      final editedHabit = container.read(habitsNotifierProvider).activeHabits.firstWhere((h) => h.id == addedHabit.id);
      expect(editedHabit.title, 'Stoic Evening Reading & Journaling');
      expect(editedHabit.xpReward, 35);

      // Toggle habit completion for today
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      await notifier.toggleHabitCompletion(editedHabit.id);

      final completedHabit = container.read(habitsNotifierProvider).activeHabits.firstWhere((h) => h.id == addedHabit.id);
      expect(completedHabit.isCompletedToday(), isTrue);
      expect(completedHabit.currentStreak, 1);
      expect(completedHabit.completedDates.contains(todayStr), isTrue);

      // Toggle again to uncomplete
      await notifier.toggleHabitCompletion(editedHabit.id);
      final uncompletedHabit = container.read(habitsNotifierProvider).activeHabits.firstWhere((h) => h.id == addedHabit.id);
      expect(uncompletedHabit.isCompletedToday(), isFalse);
      expect(uncompletedHabit.currentStreak, 0);

      // Delete habit
      await notifier.deleteHabit(addedHabit.id);
      expect(container.read(habitsNotifierProvider).activeHabits.any((h) => h.id == addedHabit.id), isFalse);
    });

    test('Routine builder adds, toggles steps, and completes protocols with bonus XP', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );

      final notifier = container.read(habitsNotifierProvider.notifier);
      final initialRoutines = container.read(habitsNotifierProvider).routines.length;

      // Add a custom routine
      await notifier.addRoutine(
        title: 'Deep Focus Morning Protocol',
        time: '07:00 AM',
        steps: const [
          RoutineStep(title: 'Black Coffee & Hydration', durationMinutes: 5),
          RoutineStep(title: 'Turn on Do Not Disturb', durationMinutes: 2),
          RoutineStep(title: 'Review Top 3 Goals', durationMinutes: 8),
        ],
        xpBonus: 120,
      );

      final routines = container.read(habitsNotifierProvider).routines;
      expect(routines.length, initialRoutines + 1);

      final routine = routines.firstWhere((r) => r.title == 'Deep Focus Morning Protocol');
      expect(routine.steps.length, 3);
      expect(routine.totalMinutes, 15);
      expect(routine.isCompletedToday(), isFalse);

      // Complete routine for today
      await notifier.completeRoutine(routine.id);
      final finishedRoutine = container.read(habitsNotifierProvider).routines.firstWhere((r) => r.id == routine.id);
      expect(finishedRoutine.isCompletedToday(), isTrue);
    });
  });

  group('FriendsLeagueNotifier & Referral Code Tests', () {
    test('Generates referral code and grants +250 XP bonus upon redeeming friend code', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );

      final friendsNotifier = container.read(friendsLeagueNotifierProvider.notifier);
      final friendsState = container.read(friendsLeagueNotifierProvider);

      expect(friendsState.myReferralCode.startsWith('SANKALP-'), isTrue);

      // Cannot redeem own referral code
      final ownResult = await friendsNotifier.redeemReferralCode(friendsState.myReferralCode);
      expect(ownResult, isFalse);

      // Redeem valid friend referral code
      final initialXp = container.read(gamificationNotifierProvider).totalXp;
      final friendResult = await friendsNotifier.redeemReferralCode('SANKALP-8M1P');
      expect(friendResult, isTrue);

      // XP increased by +250
      final updatedXp = container.read(gamificationNotifierProvider).totalXp;
      expect(updatedXp, initialXp + 250);

      // Friend added to friends list
      final updatedState = container.read(friendsLeagueNotifierProvider);
      expect(updatedState.friends.any((f) => f.referralCode == 'SANKALP-8M1P'), isTrue);

      // Cannot redeem the same code twice
      final duplicateResult = await friendsNotifier.redeemReferralCode('SANKALP-8M1P');
      expect(duplicateResult, isFalse);
    });
  });

  group('Habit UI Widget Tests', () {
    testWidgets('HabitCalendarScreen renders month navigation and habit stats', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const HabitCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Habit Calendar'), findsOneWidget);
      expect(find.text('Total Check-ins'), findsOneWidget);
      expect(find.text('Active Habits'), findsOneWidget);
    });

    testWidgets('RoutineBuilderScreen renders active protocols and New Routine trigger', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const RoutineBuilderScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Daily Protocols & Routines'), findsOneWidget);
      expect(find.text('Your Active Protocols'), findsOneWidget);
      expect(find.text('New Routine'), findsOneWidget);
      expect(find.text('Morning Monk Routine'), findsOneWidget);
    });
  });
}
