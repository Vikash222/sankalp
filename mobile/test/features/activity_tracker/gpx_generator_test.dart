import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/activity_type.dart';
import 'package:arclife/features/activity_tracker/domain/entities/location_point.dart';
import 'package:arclife/features/activity_tracker/domain/entities/tracking_session.dart';
import 'package:arclife/features/activity_tracker/domain/services/gpx_generator.dart';

void main() {
  group('GpxGenerator Unit Tests', () {
    test('Generates valid GPX 1.1 structure with trackpoints', () {
      final now = DateTime.utc(2026, 10, 2, 6, 0, 0);
      final points = [
        LocationPoint(
          latitude: 28.6139,
          longitude: 77.2090,
          altitude: 215.0,
          speed: 2.8,
          timestamp: now,
        ),
        LocationPoint(
          latitude: 28.6150,
          longitude: 77.2100,
          altitude: 216.5,
          speed: 3.1,
          timestamp: now.add(const Duration(seconds: 15)),
        ),
      ];

      final session = TrackingSession(
        clientUuid: 'test-uuid-1',
        type: ActivityType.run,
        startedAt: now,
        distanceMeters: 500.0,
        movingTimeSeconds: 150,
        points: points,
      );

      final gpx = GpxGenerator.generateGpx(session);

      expect(gpx.contains('<?xml version="1.0" encoding="UTF-8"?>'), isTrue);
      expect(gpx.contains('<trkpt lat="28.613900" lon="77.209000">'), isTrue);
      expect(gpx.contains('<ele>215.0</ele>'), isTrue);
      expect(gpx.contains('<speed>2.80</speed>'), isTrue);
      expect(gpx.contains('<name>Sankalp Running Session</name>'), isTrue);
    });

    test('Applies 200m privacy buffer correctly to exclude start/end coordinates', () {
      final now = DateTime.utc(2026, 10, 2, 6, 0, 0);
      // Start point
      final p1 = LocationPoint(
        latitude: 28.6000,
        longitude: 77.2000,
        timestamp: now,
      );
      // Point 50m away from start (within 200m)
      final p2 = LocationPoint(
        latitude: 28.6003,
        longitude: 77.2003,
        timestamp: now.add(const Duration(seconds: 10)),
      );
      // Mid point 1000m away (outside 200m)
      final p3 = LocationPoint(
        latitude: 28.6100,
        longitude: 77.2100,
        timestamp: now.add(const Duration(seconds: 100)),
      );
      // End point
      final p4 = LocationPoint(
        latitude: 28.6200,
        longitude: 77.2200,
        timestamp: now.add(const Duration(seconds: 200)),
      );

      final session = TrackingSession(
        clientUuid: 'test-privacy-uuid',
        type: ActivityType.run,
        startedAt: now,
        points: [p1, p2, p3, p4],
      );

      final gpxWithPrivacy = GpxGenerator.generateGpx(session, hidePrivacyZones: true);

      // p3 should be present, but p1, p2, p4 should be excluded by privacy buffer
      expect(gpxWithPrivacy.contains('28.610000'), isTrue);
      expect(gpxWithPrivacy.contains('28.600000'), isFalse);
      expect(gpxWithPrivacy.contains('28.620000'), isFalse);
    });
  });
}
