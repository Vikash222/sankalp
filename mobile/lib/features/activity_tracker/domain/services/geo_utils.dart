import 'dart:math' as math;
import '../entities/location_point.dart';

/// Pure mathematical geolocation utility functions for fitness calculations.
class GeoUtils {
  /// Mean Earth radius in meters according to WGS-84 sphere approximation.
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates geodesic distance between two coordinate pairs using Haversine formula.
  /// Returns distance in meters.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (lat1 == lat2 && lon1 == lon2) return 0.0;

    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final deltaPhi = _degToRad(lat2 - lat1);
    final deltaLambda = _degToRad(lon2 - lon1);

    final sinDeltaPhi2 = math.sin(deltaPhi / 2.0);
    final sinDeltaLambda2 = math.sin(deltaLambda / 2.0);

    final a = sinDeltaPhi2 * sinDeltaPhi2 +
        math.cos(phi1) * math.cos(phi2) * sinDeltaLambda2 * sinDeltaLambda2;

    final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return earthRadiusMeters * c;
  }

  /// Calculates distance in meters between two [LocationPoint] instances.
  static double distanceBetweenPoints(LocationPoint p1, LocationPoint p2) {
    return haversineDistance(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
  }

  /// Computes initial compass bearing from (lat1, lon1) to (lat2, lon2) in degrees [0..360).
  static double initialBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final deltaLambda = _degToRad(lon2 - lon1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final bearingRad = math.atan2(y, x);
    final bearingDeg = _radToDeg(bearingRad);
    return (bearingDeg + 360.0) % 360.0;
  }

  /// Calculates perpendicular distance in meters from point P to line segment (A, B).
  /// Used for the Ramer-Douglas-Peucker route compression algorithm.
  static double perpendicularDistance(
    LocationPoint p,
    LocationPoint a,
    LocationPoint b,
  ) {
    final distAB = distanceBetweenPoints(a, b);
    if (distAB == 0.0) {
      return distanceBetweenPoints(p, a);
    }

    // Convert coordinates to planar Cartesian coordinates relative to point A
    final distAP = distanceBetweenPoints(a, p);
    final distBP = distanceBetweenPoints(b, p);

    // Heron's semi-perimeter formula for triangle area
    final s = (distAB + distAP + distBP) / 2.0;
    final areaSq = s * (s - distAB) * (s - distAP) * (s - distBP);
    if (areaSq <= 0.0) return 0.0;

    final area = math.sqrt(areaSq);
    // Height = 2 * Area / Base
    return (2.0 * area) / distAB;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
