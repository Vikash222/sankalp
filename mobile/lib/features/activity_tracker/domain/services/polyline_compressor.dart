import '../entities/location_point.dart';
import 'geo_utils.dart';

/// Implements Ramer-Douglas-Peucker (RDP) polyline simplification and Google Polyline Encoding.
class PolylineCompressor {
  /// Simplifies a GPS coordinate polyline using the Ramer-Douglas-Peucker algorithm.
  /// [epsilonMeters]: Maximum allowable perpendicular deviation in meters (typically 2.0 to 4.0m).
  static List<LocationPoint> simplifyRdp(
    List<LocationPoint> points, {
    double epsilonMeters = 3.0,
  }) {
    if (points.length <= 2) return points;

    return _rdpRecursive(points, 0, points.length - 1, epsilonMeters);
  }

  static List<LocationPoint> _rdpRecursive(
    List<LocationPoint> points,
    int startIndex,
    int endIndex,
    double epsilon,
  ) {
    double maxDistance = 0.0;
    int indexWithMaxDistance = 0;

    final startPoint = points[startIndex];
    final endPoint = points[endIndex];

    for (int i = startIndex + 1; i < endIndex; i++) {
      final currentPoint = points[i];
      final distance = GeoUtils.perpendicularDistance(
        currentPoint,
        startPoint,
        endPoint,
      );

      if (distance > maxDistance) {
        maxDistance = distance;
        indexWithMaxDistance = i;
      }
    }

    if (maxDistance > epsilon) {
      // Recurse left and right
      final leftResult = _rdpRecursive(
        points,
        startIndex,
        indexWithMaxDistance,
        epsilon,
      );
      final rightResult = _rdpRecursive(
        points,
        indexWithMaxDistance,
        endIndex,
        epsilon,
      );

      // Concatenate excluding duplicate middle element
      return [
        ...leftResult.sublist(0, leftResult.length - 1),
        ...rightResult,
      ];
    } else {
      return [startPoint, endPoint];
    }
  }

  /// Encodes a list of [LocationPoint] coordinates into standard Google Encoded Polyline string format.
  /// Precision: 5 decimal places (~1.1 meter resolution).
  static String encode(List<LocationPoint> points) {
    if (points.isEmpty) return '';

    final StringBuffer result = StringBuffer();
    int lastLat = 0;
    int lastLng = 0;

    for (final point in points) {
      final latE5 = (point.latitude * 1e5).round();
      final lngE5 = (point.longitude * 1e5).round();

      final deltaLat = latE5 - lastLat;
      final deltaLng = lngE5 - lastLng;

      _encodeSignedNumber(deltaLat, result);
      _encodeSignedNumber(deltaLng, result);

      lastLat = latE5;
      lastLng = lngE5;
    }

    return result.toString();
  }

  /// Decodes a Google Encoded Polyline string back into a list of coordinate pairs [lat, lng].
  static List<List<double>> decode(String encoded) {
    final List<List<double>> coordinates = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      coordinates.add([lat / 1e5, lng / 1e5]);
    }

    return coordinates;
  }

  static void _encodeSignedNumber(int num, StringBuffer buffer) {
    int sgnNum = num < 0 ? ~(num << 1) : (num << 1);
    while (sgnNum >= 0x20) {
      buffer.writeCharCode((0x20 | (sgnNum & 0x1f)) + 63);
      sgnNum >>= 5;
    }
    buffer.writeCharCode(sgnNum + 63);
  }
}
