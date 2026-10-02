import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/activity_tracker/domain/entities/location_point.dart';
import 'package:arclife/features/activity_tracker/domain/services/polyline_compressor.dart';

void main() {
  group('PolylineCompressor Unit Tests', () {
    test('RDP algorithm compresses redundant collinear points', () {
      final t0 = DateTime.now();
      // Line of 7 points perfectly in a straight line
      final points = List.generate(
        7,
        (i) => LocationPoint(
          latitude: 28.0 + (i * 0.001),
          longitude: 77.0 + (i * 0.001),
          timestamp: t0.add(Duration(seconds: i * 5)),
        ),
      );

      final compressed = PolylineCompressor.simplifyRdp(points, epsilonMeters: 2.0);
      // Collinear points should be compressed down to start and end point (2 points)
      expect(compressed.length, 2);
      expect(compressed.first.latitude, points.first.latitude);
      expect(compressed.last.latitude, points.last.latitude);
    });

    test('Google Polyline Encoding and Decoding round-trip matches coordinates', () {
      final t0 = DateTime.now();
      final originalPoints = [
        LocationPoint(latitude: 38.5, longitude: -120.2, timestamp: t0),
        LocationPoint(latitude: 40.7, longitude: -120.95, timestamp: t0.add(const Duration(seconds: 10))),
        LocationPoint(latitude: 43.252, longitude: -126.453, timestamp: t0.add(const Duration(seconds: 20))),
      ];

      final encoded = PolylineCompressor.encode(originalPoints);
      expect(encoded, isNotEmpty);
      expect(encoded, '_p~iF~ps|U_ulLnnqC_mqNvxq`@'); // Standard Google example test vector

      final decoded = PolylineCompressor.decode(encoded);
      expect(decoded.length, originalPoints.length);

      for (int i = 0; i < originalPoints.length; i++) {
        expect(decoded[i][0], closeTo(originalPoints[i].latitude, 0.00001));
        expect(decoded[i][1], closeTo(originalPoints[i].longitude, 0.00001));
      }
    });
  });
}
