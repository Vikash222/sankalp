import '../entities/activity_type.dart';

/// Clinical MET (Metabolic Equivalent of Task) calorie estimation engine.
///
/// Standard formula:
/// Calories / min = (MET * 3.5 * weightKg) / 200
class MetCalorieCalculator {
  static const double defaultUserWeightKg = 70.0;

  /// Returns estimated calories burned for a segment duration at given speed.
  static double calculateCalories({
    required ActivityType activityType,
    required double speedMps,
    required int durationSeconds,
    double userWeightKg = defaultUserWeightKg,
  }) {
    if (durationSeconds <= 0) return 0.0;
    final weight = (userWeightKg > 20.0 && userWeightKg < 300.0)
        ? userWeightKg
        : defaultUserWeightKg;

    final speedKmh = speedMps * 3.6;
    final met = getMetForSpeed(activityType, speedKmh);

    final durationMinutes = durationSeconds / 60.0;
    final calories = ((met * 3.5 * weight) / 200.0) * durationMinutes;
    return calories;
  }

  /// Looks up speed-adjusted MET intensity value according to the Compendium of Physical Activities.
  static double getMetForSpeed(ActivityType activityType, double speedKmh) {
    switch (activityType) {
      case ActivityType.run:
        if (speedKmh < 7.5) return 6.0;
        if (speedKmh < 8.5) return 8.3;
        if (speedKmh < 10.0) return 9.8;
        if (speedKmh < 11.5) return 11.0;
        if (speedKmh < 13.0) return 11.8;
        if (speedKmh < 14.5) return 12.8;
        return 14.5;

      case ActivityType.walk:
        if (speedKmh < 3.5) return 2.5;
        if (speedKmh < 5.0) return 3.5;
        if (speedKmh < 6.5) return 4.3;
        return 5.0;

      case ActivityType.cycle:
        if (speedKmh < 16.0) return 4.0;
        if (speedKmh < 20.0) return 6.8;
        if (speedKmh < 25.0) return 8.5;
        if (speedKmh < 30.0) return 10.5;
        return 12.5;

      case ActivityType.hike:
        if (speedKmh < 4.0) return 5.3;
        return 7.3;
    }
  }
}
