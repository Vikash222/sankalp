import '../entities/activity_split.dart';
import '../entities/location_point.dart';
import 'geo_utils.dart';

/// Calculation engine for rolling pace, session average pace, and automated kilometer splits.
class PaceSplitCalculator {
  static const double splitDistanceTargetMeters = 1000.0;
  static const int rollingWindowMaxPoints = 8;

  final List<LocationPoint> _rollingPoints = [];
  final List<ActivitySplit> _completedSplits = [];

  double _lastSplitDistanceThreshold = 0.0;
  int _lastSplitMovingTimeSeconds = 0;
  double _lastSplitAltitude = 0.0;
  bool _isSplitAltitudeInitialized = false;

  List<ActivitySplit> get completedSplits => List.unmodifiable(_completedSplits);

  void reset() {
    _rollingPoints.clear();
    _completedSplits.clear();
    _lastSplitDistanceThreshold = 0.0;
    _lastSplitMovingTimeSeconds = 0;
    _lastSplitAltitude = 0.0;
    _isSplitAltitudeInitialized = false;
  }

  /// Calculates rolling current pace in seconds per kilometer over a recent window of points.
  int calculateCurrentPaceSecondsPerKm(LocationPoint newPoint) {
    _rollingPoints.add(newPoint);
    if (_rollingPoints.length > rollingWindowMaxPoints) {
      _rollingPoints.removeAt(0);
    }

    if (_rollingPoints.length < 2) {
      if (newPoint.speed > 0.5) {
        return (1000.0 / newPoint.speed).round();
      }
      return 0;
    }

    // Measure total distance and elapsed time across the rolling buffer
    double windowDistanceM = 0.0;
    for (int i = 0; i < _rollingPoints.length - 1; i++) {
      windowDistanceM += GeoUtils.distanceBetweenPoints(
        _rollingPoints[i],
        _rollingPoints[i + 1],
      );
    }

    final windowTimeSec = _rollingPoints.last.timestamp
            .difference(_rollingPoints.first.timestamp)
            .inMilliseconds /
        1000.0;

    if (windowDistanceM > 10.0 && windowTimeSec > 0.0) {
      final speedMps = windowDistanceM / windowTimeSec;
      if (speedMps > 0.3) {
        final pace = (1000.0 / speedMps).round();
        return pace.clamp(120, 3600); // Between 2:00/km and 60:00/km
      }
    }

    return 0;
  }

  /// Calculates overall session average pace in seconds per kilometer.
  int calculateAveragePaceSecondsPerKm({
    required double totalDistanceMeters,
    required int movingTimeSeconds,
  }) {
    if (totalDistanceMeters < 50.0 || movingTimeSeconds <= 0) {
      return 0;
    }
    final distanceKm = totalDistanceMeters / 1000.0;
    final avgPace = (movingTimeSeconds / distanceKm).round();
    return avgPace.clamp(120, 3600);
  }

  /// Checks if total distance crossed a new 1-kilometer milestone.
  /// If yes, records and returns the new [ActivitySplit]. Otherwise returns null.
  ActivitySplit? checkAndRecordSplit({
    required double totalDistanceMeters,
    required int movingTimeSeconds,
    required double currentAltitude,
  }) {
    if (!_isSplitAltitudeInitialized) {
      _lastSplitAltitude = currentAltitude;
      _isSplitAltitudeInitialized = true;
    }

    final nextMilestone = _lastSplitDistanceThreshold + splitDistanceTargetMeters;

    if (totalDistanceMeters >= nextMilestone) {
      final splitIndex = _completedSplits.length + 1;
      final splitDistance = splitDistanceTargetMeters;
      final splitDuration = movingTimeSeconds - _lastSplitMovingTimeSeconds;
      final splitElevation = currentAltitude - _lastSplitAltitude;

      final pace = splitDuration > 0
          ? ((splitDuration / (splitDistance / 1000.0)).round())
          : 0;

      final split = ActivitySplit(
        splitIndex: splitIndex,
        distanceMeters: splitDistance,
        durationSeconds: splitDuration,
        paceSecondsPerKm: pace,
        elevationChangeMeters: splitElevation,
      );

      _completedSplits.add(split);
      _lastSplitDistanceThreshold = nextMilestone;
      _lastSplitMovingTimeSeconds = movingTimeSeconds;
      _lastSplitAltitude = currentAltitude;

      return split;
    }

    return null;
  }

  /// Generates the final partial split upon completing a workout session.
  ActivitySplit? finalizeLastPartialSplit({
    required double totalDistanceMeters,
    required int movingTimeSeconds,
    required double currentAltitude,
  }) {
    final remainingDistance = totalDistanceMeters - _lastSplitDistanceThreshold;
    if (remainingDistance < 100.0) {
      return null; // Ignore tiny residual distance < 100m
    }

    final splitIndex = _completedSplits.length + 1;
    final splitDuration = movingTimeSeconds - _lastSplitMovingTimeSeconds;
    final splitElevation = currentAltitude - _lastSplitAltitude;
    final pace = (remainingDistance > 0 && splitDuration > 0)
        ? (splitDuration / (remainingDistance / 1000.0)).round()
        : 0;

    final partialSplit = ActivitySplit(
      splitIndex: splitIndex,
      distanceMeters: remainingDistance,
      durationSeconds: splitDuration,
      paceSecondsPerKm: pace,
      elevationChangeMeters: splitElevation,
    );

    _completedSplits.add(partialSplit);
    return partialSplit;
  }
}
