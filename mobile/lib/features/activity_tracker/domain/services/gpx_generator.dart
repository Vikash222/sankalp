import 'package:intl/intl.dart';
import '../entities/location_point.dart';
import '../entities/tracking_session.dart';
import 'geo_utils.dart';

/// Pure-Dart service generating standard GPX 1.1 XML representations of workouts.
class GpxGenerator {
  /// Converts a [TrackingSession] into a valid GPX 1.1 string.
  ///
  /// If [hidePrivacyZones] is true, points within [privacyRadiusMeters] (default 200m)
  /// of the start and end coordinates are excluded from the exported track.
  static String generateGpx(
    TrackingSession session, {
    bool hidePrivacyZones = false,
    double privacyRadiusMeters = 200.0,
  }) {
    final points = session.points;
    if (points.isEmpty) {
      return _buildEmptyGpx(session);
    }

    final filteredPoints = hidePrivacyZones
        ? _applyPrivacyBuffer(points, privacyRadiusMeters)
        : points;

    final isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    final formattedStartTime = isoFormat.format(session.startedAt.toUtc());

    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="Sankalp Mobile - https://sankalp.app"');
    buffer.writeln('  xmlns="http://www.topografix.com/GPX/1/1"');
    buffer.writeln('  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    buffer.writeln('  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');
    
    // Metadata
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>Sankalp ${session.type.displayName} Session</name>');
    buffer.writeln('    <time>$formattedStartTime</time>');
    buffer.writeln('  </metadata>');

    // Track
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${session.type.displayName} Workout</name>');
    buffer.writeln('    <type>${session.type.name}</type>');
    buffer.writeln('    <trkseg>');

    for (final pt in filteredPoints) {
      final ptTime = isoFormat.format(pt.timestamp.toUtc());
      buffer.writeln('      <trkpt lat="${pt.latitude.toStringAsFixed(6)}" lon="${pt.longitude.toStringAsFixed(6)}">');
      buffer.writeln('        <ele>${pt.altitude.toStringAsFixed(1)}</ele>');
      buffer.writeln('        <time>$ptTime</time>');
      if (pt.speed > 0) {
        buffer.writeln('        <speed>${pt.speed.toStringAsFixed(2)}</speed>');
      }
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }

  static List<LocationPoint> _applyPrivacyBuffer(
    List<LocationPoint> points,
    double radiusMeters,
  ) {
    if (points.length < 3) return points;

    final startPoint = points.first;
    final endPoint = points.last;

    return points.where((pt) {
      final distFromStart = GeoUtils.haversineDistance(
        startPoint.latitude,
        startPoint.longitude,
        pt.latitude,
        pt.longitude,
      );
      final distFromEnd = GeoUtils.haversineDistance(
        endPoint.latitude,
        endPoint.longitude,
        pt.latitude,
        pt.longitude,
      );

      // Exclude points that fall within privacy radius of start or end
      return distFromStart >= radiusMeters && distFromEnd >= radiusMeters;
    }).toList();
  }

  static String _buildEmptyGpx(TrackingSession session) {
    final isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    final formattedStartTime = isoFormat.format(session.startedAt.toUtc());

    return '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<gpx version="1.1" creator="Sankalp Mobile - https://sankalp.app"\n'
        '  xmlns="http://www.topografix.com/GPX/1/1">\n'
        '  <metadata>\n'
        '    <name>Sankalp ${session.type.displayName} Session</name>\n'
        '    <time>$formattedStartTime</time>\n'
        '  </metadata>\n'
        '  <trk>\n'
        '    <name>${session.type.displayName} Workout</name>\n'
        '    <type>${session.type.name}</type>\n'
        '    <trkseg/>\n'
        '  </trk>\n'
        '</gpx>';
  }
}
