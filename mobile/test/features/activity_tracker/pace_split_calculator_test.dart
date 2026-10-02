import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/location_point.dart';
import 'package:arclife/features/activity_tracker/domain/services/pace_split_calculator.dart';

void main() {
  group('PaceSplitCalculator Unit Tests', () {
    late PaceSplitCalculator calculator;

    setUp(() {
      calculator = PaceSplitCalculator();
    });

    test('Average pace calculation is accurate', () {
      // 5,000 meters in 1,500 seconds (25 mins) -> exactly 300 sec/km (05:00 min/km)
      final avgPace = calculator.calculateAveragePaceSecondsPerKm(
        totalDistanceMeters: 5000.0,
        movingTimeSeconds: 1500,
      );
      expect(avgPace, 300);
    });

    test('Zero distance returns 0 pace without division by zero', () {
      final avgPace = calculator.calculateAveragePaceSecondsPerKm(
        totalDistanceMeters: 0.0,
        movingTimeSeconds: 500,
      );
      expect(avgPace, 0);
    });

    test('Records a split precisely when passing 1000m mark', () {
      final split1 = calculator.checkAndRecordSplit(
        totalDistanceMeters: 1005.0,
        movingTimeSeconds: 320,
        currentAltitude: 220.0,
      );

      expect(split1, isNotNull);
      expect(split1?.splitIndex, 1);
      expect(split1?.distanceMeters, 1000.0);
      expect(split1?.durationSeconds, 320);
      expect(split1?.paceSecondsPerKm, 320); // 320 sec/km = 05:20/km

      // If distance hasn't reached 2000m, returns null
      final splitNoTrigger = calculator.checkAndRecordSplit(
        totalDistanceMeters: 1600.0,
        movingTimeSeconds: 500,
        currentAltitude: 225.0,
      );
      expect(splitNoTrigger, isNull);

      // Reaches 2000m milestone
      final split2 = calculator.checkAndRecordSplit(
        totalDistanceMeters: 2010.0,
        movingTimeSeconds: 630, // 310 seconds for split 2
        currentAltitude: 230.0,
      );
      expect(split2, isNotNull);
      expect(split2?.splitIndex, 2);
      expect(split2?.durationSeconds, 310);
    });

    test('Calculates rolling current pace across recent points', () {
      final t0 = DateTime.now();
      final p1 = LocationPoint(
        latitude: 28.000,
        longitude: 77.000,
        speed: 3.33, // ~12 km/h -> 5:00 min/km (300 sec/km)
        timestamp: t0,
      );
      final p2 = LocationPoint(
        latitude: 28.0005,
        longitude: 77.000,
        speed: 3.33,
        timestamp: t0.add(const Duration(seconds: 15)),
      );

      calculator.calculateCurrentPaceSecondsPerKm(p1);
      final pace = calculator.calculateCurrentPaceSecondsPerKm(p2);
      expect(pace, greaterThan(250));
      expect(pace, lessThan(350));
    });
  });
}
