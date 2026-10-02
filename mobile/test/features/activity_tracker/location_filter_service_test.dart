import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/activity_type.dart';
import 'package:arclife/features/activity_tracker/domain/entities/location_point.dart';
import 'package:arclife/features/activity_tracker/domain/services/location_filter_service.dart';

void main() {
  group('LocationFilterService Unit Tests', () {
    late LocationFilterService filterService;

    setUp(() {
      filterService = LocationFilterService();
    });

    test('Rejects point with accuracy > 25 meters', () {
      final point = LocationPoint(
        latitude: 28.6129,
        longitude: 77.2295,
        accuracy: 32.5,
        speed: 3.0,
        timestamp: DateTime.now(),
      );

      final result = filterService.evaluatePoint(
        rawPoint: point,
        previousPoint: null,
        activityType: ActivityType.run,
      );

      expect(result.isAccepted, isFalse);
      expect(result.rejectionReason, contains('Inaccurate GPS lock'));
    });

    test('Accepts clean first point and initializes elevation', () {
      final point = LocationPoint(
        latitude: 28.6129,
        longitude: 77.2295,
        accuracy: 8.0,
        altitude: 215.0,
        speed: 2.8,
        timestamp: DateTime.now(),
      );

      final result = filterService.evaluatePoint(
        rawPoint: point,
        previousPoint: null,
        activityType: ActivityType.run,
      );

      expect(result.isAccepted, isTrue);
      expect(result.smoothedPoint?.altitude, 215.0);
      expect(result.segmentDistanceMeters, 0.0);
    });

    test('Rejects impossible running speed jumps (> 25 km/h)', () {
      final t0 = DateTime.now();
      final p1 = LocationPoint(
        latitude: 28.6129,
        longitude: 77.2295,
        accuracy: 5.0,
        speed: 3.0,
        timestamp: t0,
      );

      // Simulates jump of 200 meters in 2 seconds = 100 m/s = 360 km/h
      final p2 = LocationPoint(
        latitude: 28.6147,
        longitude: 77.2295,
        accuracy: 5.0,
        speed: 100.0,
        timestamp: t0.add(const Duration(seconds: 2)),
      );

      filterService.evaluatePoint(
        rawPoint: p1,
        previousPoint: null,
        activityType: ActivityType.run,
      );

      final result = filterService.evaluatePoint(
        rawPoint: p2,
        previousPoint: p1,
        activityType: ActivityType.run,
      );

      expect(result.isAccepted, isFalse);
      expect(result.rejectionReason, contains('Impossible speed jump'));
    });

    test('Suppresses stationary GPS jitter drift when speed is near zero', () {
      final t0 = DateTime.now();
      final p1 = LocationPoint(
        latitude: 28.6129,
        longitude: 77.2295,
        accuracy: 6.0,
        speed: 0.0,
        timestamp: t0,
      );

      // 0.5 meter drift in 3 seconds with 0 speed
      final p2 = LocationPoint(
        latitude: 28.612904,
        longitude: 77.229503,
        accuracy: 7.0,
        speed: 0.1,
        timestamp: t0.add(const Duration(seconds: 3)),
      );

      final result = filterService.evaluatePoint(
        rawPoint: p2,
        previousPoint: p1,
        activityType: ActivityType.walk,
      );

      expect(result.isAccepted, isFalse);
      expect(result.rejectionReason, contains('Stationary GPS drift suppression'));
    });
  });
}
