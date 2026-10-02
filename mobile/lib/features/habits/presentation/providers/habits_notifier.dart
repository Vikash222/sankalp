import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/sync/offline_sync_engine.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../gamification/presentation/providers/gamification_notifier.dart';
import '../../domain/entities/habit_model.dart';

class HabitsState {
  final List<HabitModel> habits;
  final List<RoutineModel> routines;
  final DateTime selectedDate;
  final bool isLoading;

  const HabitsState({
    required this.habits,
    required this.routines,
    required this.selectedDate,
    this.isLoading = false,
  });

  HabitsState copyWith({
    List<HabitModel>? habits,
    List<RoutineModel>? routines,
    DateTime? selectedDate,
    bool? isLoading,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      routines: routines ?? this.routines,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<HabitModel> get activeHabits => habits.where((h) => !h.isArchived).toList();

  List<HabitModel> habitsForTimeOfDay(HabitTimeOfDay time) {
    return activeHabits.where((h) => h.timeOfDay == time || (time == HabitTimeOfDay.morning && h.timeOfDay == HabitTimeOfDay.anytime)).toList();
  }

  double get todayCompletionRate {
    final active = activeHabits;
    if (active.isEmpty) return 0.0;
    final completed = active.where((h) => h.isCompletedToday()).length;
    return completed / active.length;
  }
}

class HabitsNotifier extends Notifier<HabitsState> {
  static const String _habitsKey = 'sankalp_custom_habits';
  static const String _routinesKey = 'sankalp_custom_routines';

  @override
  HabitsState build() {
    final state = HabitsState(
      habits: _defaultHabits(),
      routines: _defaultRoutines(),
      selectedDate: DateTime.now(),
      isLoading: true,
    );

    Future.microtask(() => _loadFromStorage());
    return state;
  }

  Future<void> _loadFromStorage() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final rawHabits = storage.prefs.getString(_habitsKey);
      final rawRoutines = storage.prefs.getString(_routinesKey);

      if (rawHabits != null && rawHabits.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawHabits);
        final loadedHabits = list.map((e) => HabitModel.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(habits: loadedHabits);
      }

      if (rawRoutines != null && rawRoutines.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawRoutines);
        final loadedRoutines = list.map((e) => RoutineModel.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(routines: loadedRoutines);
      }

      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final habitsJson = jsonEncode(state.habits.map((h) => h.toJson()).toList());
      final routinesJson = jsonEncode(state.routines.map((r) => r.toJson()).toList());

      await storage.prefs.setString(_habitsKey, habitsJson);
      await storage.prefs.setString(_routinesKey, routinesJson);
    } catch (_) {}
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  // --- HABIT CRUD & COMPLETION ---

  Future<void> addHabit({
    required String title,
    String description = '',
    required HabitCategory category,
    HabitTimeOfDay timeOfDay = HabitTimeOfDay.anytime,
    int xpReward = 20,
    String? reminderTime,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final habit = HabitModel(
      id: newId,
      title: title,
      description: description,
      category: category,
      timeOfDay: timeOfDay,
      xpReward: xpReward,
      currentStreak: 0,
      bestStreak: 0,
      completedDates: [],
      reminderTime: reminderTime,
    );

    final updated = [...state.habits, habit];
    state = state.copyWith(habits: updated);
    await _saveToStorage();
  }

  Future<void> editHabit({
    required int id,
    required String title,
    String description = '',
    required HabitCategory category,
    HabitTimeOfDay timeOfDay = HabitTimeOfDay.anytime,
    int xpReward = 20,
    String? reminderTime,
  }) async {
    final updated = state.habits.map((h) {
      if (h.id == id) {
        return h.copyWith(
          title: title,
          description: description,
          category: category,
          timeOfDay: timeOfDay,
          xpReward: xpReward,
          reminderTime: reminderTime,
        );
      }
      return h;
    }).toList();

    state = state.copyWith(habits: updated);
    await _saveToStorage();
  }

  Future<void> deleteHabit(int id) async {
    final updated = state.habits.where((h) => h.id != id).toList();
    state = state.copyWith(habits: updated);
    await _saveToStorage();
  }

  Future<void> toggleHabitCompletion(int id, [DateTime? forDate]) async {
    final date = forDate ?? state.selectedDate;
    final dateStr = date.toIso8601String().substring(0, 10);

    HabitModel? targetHabit;
    bool wasCompleted = false;

    final updated = state.habits.map((h) {
      if (h.id == id) {
        targetHabit = h;
        final dates = List<String>.from(h.completedDates);
        wasCompleted = dates.contains(dateStr);

        if (wasCompleted) {
          dates.remove(dateStr);
          final streak = (h.currentStreak - 1).clamp(0, 9999);
          return h.copyWith(completedDates: dates, currentStreak: streak);
        } else {
          dates.add(dateStr);
          final streak = h.currentStreak + 1;
          final best = streak > h.bestStreak ? streak : h.bestStreak;
          return h.copyWith(completedDates: dates, currentStreak: streak, bestStreak: best);
        }
      }
      return h;
    }).toList();

    state = state.copyWith(habits: updated);
    await _saveToStorage();

    if (targetHabit != null) {
      if (!wasCompleted) {
        // Award XP
        ref.read(gamificationNotifierProvider.notifier).addXp(targetHabit!.xpReward);
        // Enqueue offline check-in sync
        ref.read(offlineSyncEngineProvider).enqueueHabitCheckIn(
              habitId: targetHabit!.id,
              date: dateStr,
              completed: true,
            );
      }
    }
  }

  // --- ROUTINE CRUD & COMPLETION ---

  Future<void> addRoutine({
    required String title,
    required String time,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    required List<RoutineStep> steps,
    bool isNotificationEnabled = true,
    int xpBonus = 100,
  }) async {
    final routine = RoutineModel(
      id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      time: time,
      daysOfWeek: daysOfWeek,
      steps: steps,
      isNotificationEnabled: isNotificationEnabled,
      xpBonus: xpBonus,
    );

    final updated = [...state.routines, routine];
    state = state.copyWith(routines: updated);
    await _saveToStorage();
  }

  Future<void> editRoutine({
    required String id,
    required String title,
    required String time,
    required List<int> daysOfWeek,
    required List<RoutineStep> steps,
    required bool isNotificationEnabled,
  }) async {
    final updated = state.routines.map((r) {
      if (r.id == id) {
        return r.copyWith(
          title: title,
          time: time,
          daysOfWeek: daysOfWeek,
          steps: steps,
          isNotificationEnabled: isNotificationEnabled,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(routines: updated);
    await _saveToStorage();
  }

  Future<void> deleteRoutine(String id) async {
    final updated = state.routines.where((r) => r.id != id).toList();
    state = state.copyWith(routines: updated);
    await _saveToStorage();
  }

  Future<void> toggleRoutineStep(String routineId, int stepIndex) async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final updated = state.routines.map((r) {
      if (r.id == routineId && stepIndex < r.steps.length) {
        final newSteps = List<RoutineStep>.from(r.steps);
        final current = newSteps[stepIndex];
        newSteps[stepIndex] = current.copyWith(isCompleted: !current.isCompleted);

        // Check if all steps are now finished
        final allDone = newSteps.every((s) => s.isCompleted);
        return r.copyWith(
          steps: newSteps,
          lastCompletedDate: allDone ? todayStr : r.lastCompletedDate,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(routines: updated);
    await _saveToStorage();
  }

  Future<void> completeRoutine(String routineId) async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    RoutineModel? completed;

    final updated = state.routines.map((r) {
      if (r.id == routineId) {
        completed = r;
        final allDoneSteps = r.steps.map((s) => s.copyWith(isCompleted: true)).toList();
        return r.copyWith(
          steps: allDoneSteps,
          lastCompletedDate: todayStr,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(routines: updated);
    await _saveToStorage();

    if (completed != null) {
      ref.read(gamificationNotifierProvider.notifier).addXp(completed!.xpBonus);
    }
  }

  // --- CALENDAR & ANALYTICS HELPERS ---

  double getCompletionRateForDate(DateTime date) {
    final dateStr = date.toIso8601String().substring(0, 10);
    final active = state.activeHabits;
    if (active.isEmpty) return 0.0;
    final done = active.where((h) => h.isCompletedOn(dateStr)).length;
    return done / active.length;
  }

  int getCompletedCountForDate(DateTime date) {
    final dateStr = date.toIso8601String().substring(0, 10);
    return state.activeHabits.where((h) => h.isCompletedOn(dateStr)).length;
  }

  static List<HabitModel> _defaultHabits() {
    return [
      const HabitModel(
        id: 101,
        title: 'Cold Shower Immersion',
        description: 'Mitochondrial boost and morning resilience reset.',
        category: HabitCategory.fitness,
        timeOfDay: HabitTimeOfDay.morning,
        xpReward: 20,
        currentStreak: 0,
        bestStreak: 0,
        completedDates: [],
        reminderTime: '06:30',
      ),
      const HabitModel(
        id: 102,
        title: 'Deep Work Block (45 Mins)',
        description: 'Zero phone interruptions, maximum cognitive flow.',
        category: HabitCategory.focus,
        timeOfDay: HabitTimeOfDay.afternoon,
        xpReward: 35,
        currentStreak: 0,
        bestStreak: 0,
        completedDates: [],
        reminderTime: '11:00',
      ),
      const HabitModel(
        id: 103,
        title: 'Evening Journal & Stoic Review',
        description: 'Audit the day, log gratitude, and plan tomorrow.',
        category: HabitCategory.mindset,
        timeOfDay: HabitTimeOfDay.evening,
        xpReward: 20,
        currentStreak: 0,
        bestStreak: 0,
        completedDates: [],
        reminderTime: '21:30',
      ),
      const HabitModel(
        id: 104,
        title: 'Morning Sunlight & Hydration',
        description: '500ml mineral water and 15 mins outdoor sunlight.',
        category: HabitCategory.health,
        timeOfDay: HabitTimeOfDay.morning,
        xpReward: 15,
        currentStreak: 0,
        bestStreak: 0,
        completedDates: [],
        reminderTime: '07:00',
      ),
    ];
  }

  static List<RoutineModel> _defaultRoutines() {
    return [
      const RoutineModel(
        id: 'morning_monk',
        title: 'Morning Monk Routine',
        time: '06:30 AM',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        steps: [
          RoutineStep(title: 'Hydrate with 500ml water & pink salt', durationMinutes: 2, isCompleted: false),
          RoutineStep(title: '15 mins outdoor sunlight & breathwork', durationMinutes: 15, isCompleted: false),
          RoutineStep(title: 'Cold water immersion / shower', durationMinutes: 5, isCompleted: false),
        ],
        isNotificationEnabled: true,
        xpBonus: 100,
      ),
      const RoutineModel(
        id: 'evening_winddown',
        title: 'Evening Wind-Down Protocol',
        time: '09:30 PM',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        steps: [
          RoutineStep(title: 'Screens off / dim warm lights', durationMinutes: 5, isCompleted: false),
          RoutineStep(title: 'Read 10 pages non-fiction book', durationMinutes: 20, isCompleted: false),
          RoutineStep(title: 'Nightly Stoic review & habit audit', durationMinutes: 10, isCompleted: false),
        ],
        isNotificationEnabled: true,
        xpBonus: 80,
      ),
    ];
  }
}

final habitsNotifierProvider =
    NotifierProvider<HabitsNotifier, HabitsState>(HabitsNotifier.new);
