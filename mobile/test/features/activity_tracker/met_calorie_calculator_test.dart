import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/activity_type.dart';
import 'package:arclife/features/activity_tracker/domain/services/met_calorie_calculator.dart';

void main() {
  group('MetCalorieCalculator Unit Tests', () {
    test('Zero duration yields zero calories burned', () {
      final calories = MetCalorieCalculator.calculateCalories(
        activityType: ActivityType.run,
        speedMps: 2.78, // 10 km/h
        durationSeconds: 0,
        userWeightKg: 70.0,
      );
      expect(calories, 0.0);
    });

    test('Standard 70kg runner at 10 km/h for 30 minutes burns ~360 kcal', () {
      // 10 km/h -> MET 11.0
      // Calories / min = (11.0 * 3.5 * 70) / 200 = 13.475 kcal/min
      // 30 min = ~404.25 kcal
      final calories = MetCalorieCalculator.calculateCalories(
        activityType: ActivityType.run,
        speedMps: 2.78, // 10 km/h
        durationSeconds: 1800, // 30 mins
        userWeightKg: 70.0,
      );
      expect(calories, greaterThan(350));
      expect(calories, lessThan(450));
    });

    test('Heavier individual burns proportionally more calories', () {
      final calories70 = MetCalorieCalculator.calculateCalories(
        activityType: ActivityType.walk,
        speedMps: 1.39, // 5 km/h
        durationSeconds: 3600,
        userWeightKg: 70.0,
      );
      final calories90 = MetCalorieCalculator.calculateCalories(
        activityType: ActivityType.walk,
        speedMps: 1.39, // 5 km/h
        durationSeconds: 3600,
        userWeightKg: 90.0,
      );
      expect(calories90, greaterThan(calories70));
    });

    test('Higher running speed selects higher MET coefficient', () {
      final slowRunMet = MetCalorieCalculator.getMetForSpeed(ActivityType.run, 8.0);
      final fastRunMet = MetCalorieCalculator.getMetForSpeed(ActivityType.run, 14.0);
      expect(fastRunMet, greaterThan(slowRunMet));
    });
  });
}
