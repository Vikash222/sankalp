import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../domain/entities/tracking_session.dart';

class WeeklyWorkoutStats {
  final double distanceKm;
  final int durationSeconds;
  final int calories;
  final int sessionCount;

  const WeeklyWorkoutStats({
    required this.distanceKm,
    required this.durationSeconds,
    required this.calories,
    required this.sessionCount,
  });

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m';
    return '0m';
  }

  String get formattedCalories => calories.toString();
  String get formattedSessions => sessionCount.toString();
}

class WorkoutStorage {
  static const String _keyHistory = 'sankalp_workout_history';
  final TokenStorage _tokenStorage;

  WorkoutStorage(this._tokenStorage);

  Future<void> saveWorkout(TrackingSession session) async {
    final workouts = await getWorkouts();
    final updated = [
      session,
      ...workouts.where((w) => w.clientUuid != session.clientUuid),
    ];
    final jsonStr = jsonEncode(updated.map((w) => w.toJson()).toList());
    await _tokenStorage.prefs.setString(_keyHistory, jsonStr);
  }

  Future<List<TrackingSession>> getWorkouts() async {
    final raw = _tokenStorage.prefs.getString(_keyHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => TrackingSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<WeeklyWorkoutStats> getWeeklyStats() async {
    final workouts = await getWorkouts();
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final thisWeek =
        workouts.where((w) => w.startedAt.isAfter(oneWeekAgo)).toList();

    double totalDistM = 0;
    int totalMovingSec = 0;
    int totalCals = 0;

    for (final w in thisWeek) {
      totalDistM += w.distanceMeters;
      totalMovingSec += w.movingTimeSeconds;
      totalCals += w.calories;
    }

    return WeeklyWorkoutStats(
      distanceKm: totalDistM / 1000.0,
      durationSeconds: totalMovingSec,
      calories: totalCals,
      sessionCount: thisWeek.length,
    );
  }

  Future<void> deleteWorkout(String clientUuid) async {
    final workouts = await getWorkouts();
    final updated = workouts.where((w) => w.clientUuid != clientUuid).toList();
    final jsonStr = jsonEncode(updated.map((w) => w.toJson()).toList());
    await _tokenStorage.prefs.setString(_keyHistory, jsonStr);
  }
}

final workoutStorageProvider = Provider<WorkoutStorage>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return WorkoutStorage(tokenStorage);
});
