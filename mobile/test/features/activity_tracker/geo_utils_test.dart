import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/location_point.dart';
import 'package:arclife/features/activity_tracker/domain/services/geo_utils.dart';

void main() {
  group('GeoUtils Unit Tests', () {
    test('Haversine distance between identical points is 0', () {
      final distance = GeoUtils.haversineDistance(28.6129, 77.2295, 28.6129, 77.2295);
      expect(distance, 0.0);
    });

    test('Haversine distance calculates accurate geodesic distance', () {
      // India Gate (28.6129, 77.2295) to Rashtrapati Bhavan (28.6143, 77.1995)
      // Geodesic distance is approximately 2.93 km (~2930 meters)
      final distance = GeoUtils.haversineDistance(28.6129, 77.2295, 28.6143, 77.1995);
      expect(distance, greaterThan(2900));
      expect(distance, lessThan(3000));
    });

    test('Initial bearing from South to North is ~0/360 degrees', () {
      final bearing = GeoUtils.initialBearing(10.0, 77.0, 11.0, 77.0);
      expect(bearing, closeTo(0.0, 0.1));
    });

    test('Perpendicular distance from collinear point is zero', () {
      final pA = LocationPoint(
        latitude: 28.0,
        longitude: 77.0,
        timestamp: DateTime.now(),
      );
      final pB = LocationPoint(
        latitude: 28.002,
        longitude: 77.0,
        timestamp: DateTime.now(),
      );
      final pMid = LocationPoint(
        latitude: 28.001,
        longitude: 77.0,
        timestamp: DateTime.now(),
      );

      final perpDist = GeoUtils.perpendicularDistance(pMid, pA, pB);
      expect(perpDist, closeTo(0.0, 0.1));
    });
  });
}
