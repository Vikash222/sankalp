import '../entities/activity_type.dart';
import '../entities/location_point.dart';
import 'geo_utils.dart';

/// Result of evaluating an incoming raw GPS point through the filter pipeline.
class FilterResult {
  final bool isAccepted;
  final String? rejectionReason;
  final LocationPoint? smoothedPoint;
  final double segmentDistanceMeters;
  final double elevationGainMeters;

  const FilterResult({
    required this.isAccepted,
    this.rejectionReason,
    this.smoothedPoint,
    this.segmentDistanceMeters = 0.0,
    this.elevationGainMeters = 0.0,
  });

  factory FilterResult.rejected(String reason) => FilterResult(
        isAccepted: false,
        rejectionReason: reason,
      );

  factory FilterResult.accepted(
    LocationPoint point,
    double distanceM,
    double elevationGainM,
  ) =>
      FilterResult(
        isAccepted: true,
        smoothedPoint: point,
        segmentDistanceMeters: distanceM,
        elevationGainMeters: elevationGainM,
      );
}

/// Production GPS filter engine for accuracy thresholding, jitter suppression,
/// speed outlier rejection, and barometric/GPS elevation smoothing.
class LocationFilterService {
  /// Strict cutoff: GPS points with horizontal accuracy worse than 25m are rejected.
  static const double maxAllowedAccuracyMeters = 25.0;

  /// Minimum movement threshold to prevent phantom distance drift while standing still.
  static const double minMovementThresholdMeters = 1.2;

  /// Smoothing factor for exponential moving average on altitude (0.0 < alpha <= 1.0).
  static const double elevationAlpha = 0.25;

  /// Minimum elevation change (in meters) to accumulate positive gain.
  static const double minElevationStepMeters = 0.8;

  double _smoothedAltitude = 0.0;
  bool _isAltitudeInitialized = false;

  void reset() {
    _smoothedAltitude = 0.0;
    _isAltitudeInitialized = false;
  }

  FilterResult evaluatePoint({
    required LocationPoint rawPoint,
    required LocationPoint? previousPoint,
    required ActivityType activityType,
  }) {
    // 1. Boundary & sanity check
    if (rawPoint.latitude == 0.0 && rawPoint.longitude == 0.0) {
      return FilterResult.rejected('Null Island coordinates (0, 0)');
    }
    if (rawPoint.latitude < -90.0 || rawPoint.latitude > 90.0) {
      return FilterResult.rejected('Latitude out of range');
    }
    if (rawPoint.longitude < -180.0 || rawPoint.longitude > 180.0) {
      return FilterResult.rejected('Longitude out of range');
    }

    // 2. Accuracy thresholding
    if (rawPoint.accuracy > maxAllowedAccuracyMeters) {
      return FilterResult.rejected(
        'Inaccurate GPS lock: ${rawPoint.accuracy.toStringAsFixed(1)}m > ${maxAllowedAccuracyMeters}m',
      );
    }

    // First point of session
    if (previousPoint == null) {
      _smoothedAltitude = rawPoint.altitude;
      _isAltitudeInitialized = true;
      return FilterResult.accepted(rawPoint, 0.0, 0.0);
    }

    // 3. Chronological validity
    final timeDeltaMs = rawPoint.timestamp.difference(previousPoint.timestamp).inMilliseconds;
    if (timeDeltaMs <= 0) {
      return FilterResult.rejected('Non-positive time delta between points');
    }
    final timeDeltaSec = timeDeltaMs / 1000.0;

    // 4. Geodesic distance calculation
    final rawDistance = GeoUtils.distanceBetweenPoints(previousPoint, rawPoint);

    // 5. Stationary jitter filter
    // If movement is smaller than 1.2m and reported speed is near zero, suppress phantom drift
    if (rawDistance < minMovementThresholdMeters && rawPoint.speed < 0.3) {
      return FilterResult.rejected('Stationary GPS drift suppression');
    }

    // 6. Calculated speed outlier check
    final calculatedSpeedMps = rawDistance / timeDeltaSec;
    final maxSpeed = activityType.maxRealisticSpeedMps;

    if (calculatedSpeedMps > maxSpeed) {
      return FilterResult.rejected(
        'Impossible speed jump for ${activityType.name}: '
        '${(calculatedSpeedMps * 3.6).toStringAsFixed(1)} km/h > ${(maxSpeed * 3.6).toStringAsFixed(1)} km/h',
      );
    }

    // 7. Elevation smoothing & gain calculation
    if (!_isAltitudeInitialized) {
      _smoothedAltitude = rawPoint.altitude;
      _isAltitudeInitialized = true;
    }

    final newSmoothedAlt = (elevationAlpha * rawPoint.altitude) +
        ((1.0 - elevationAlpha) * _smoothedAltitude);
    final altitudeDelta = newSmoothedAlt - _smoothedAltitude;
    double gain = 0.0;
    if (altitudeDelta > minElevationStepMeters) {
      gain = altitudeDelta;
    }
    _smoothedAltitude = newSmoothedAlt;

    final acceptedPoint = rawPoint.copyWith(
      altitude: _smoothedAltitude,
      speed: rawPoint.speed > 0.0 ? rawPoint.speed : calculatedSpeedMps,
    );

    return FilterResult.accepted(acceptedPoint, rawDistance, gain);
  }
}
