import 'activity_type.dart';
import 'activity_split.dart';
import 'location_point.dart';

/// Complete live and persisted model representing an activity workout session.
class TrackingSession {
  final String clientUuid;
  final ActivityType type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isTracking;
  final bool isPaused;
  final double distanceMeters;
  final int movingTimeSeconds;
  final int elapsedTimeSeconds;
  final double currentSpeedMps;
  final double maxSpeedMps;
  final int currentPaceSecondsPerKm;
  final int avgPaceSecondsPerKm;
  final double elevationGainMeters;
  final int calories;
  final List<LocationPoint> points;
  final List<ActivitySplit> splits;
  final double lastAccuracy;

  const TrackingSession({
    required this.clientUuid,
    required this.type,
    required this.startedAt,
    this.endedAt,
    this.isTracking = false,
    this.isPaused = false,
    this.distanceMeters = 0.0,
    this.movingTimeSeconds = 0,
    this.elapsedTimeSeconds = 0,
    this.currentSpeedMps = 0.0,
    this.maxSpeedMps = 0.0,
    this.currentPaceSecondsPerKm = 0,
    this.avgPaceSecondsPerKm = 0,
    this.elevationGainMeters = 0.0,
    this.calories = 0,
    this.points = const [],
    this.splits = const [],
    this.lastAccuracy = 0.0,
  });

  String get formattedDistanceKm => (distanceMeters / 1000.0).toStringAsFixed(2);

  String get formattedMovingTime {
    final h = movingTimeSeconds ~/ 3600;
    final m = (movingTimeSeconds % 3600) ~/ 60;
    final s = movingTimeSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedCurrentPace => _formatPace(currentPaceSecondsPerKm);

  String get formattedAvgPace => _formatPace(avgPaceSecondsPerKm);

  bool get isGpsSignalGood => lastAccuracy > 0 && lastAccuracy <= 15.0;

  static String _formatPace(int paceSec) {
    if (paceSec <= 0 || paceSec > 3599) return '--:--';
    final m = paceSec ~/ 60;
    final s = paceSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TrackingSession copyWith({
    String? clientUuid,
    ActivityType? type,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isTracking,
    bool? isPaused,
    double? distanceMeters,
    int? movingTimeSeconds,
    int? elapsedTimeSeconds,
    double? currentSpeedMps,
    double? maxSpeedMps,
    int? currentPaceSecondsPerKm,
    int? avgPaceSecondsPerKm,
    double? elevationGainMeters,
    int? calories,
    List<LocationPoint>? points,
    List<ActivitySplit>? splits,
    double? lastAccuracy,
  }) {
    return TrackingSession(
      clientUuid: clientUuid ?? this.clientUuid,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isTracking: isTracking ?? this.isTracking,
      isPaused: isPaused ?? this.isPaused,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
      elapsedTimeSeconds: elapsedTimeSeconds ?? this.elapsedTimeSeconds,
      currentSpeedMps: currentSpeedMps ?? this.currentSpeedMps,
      maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
      currentPaceSecondsPerKm:
          currentPaceSecondsPerKm ?? this.currentPaceSecondsPerKm,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      calories: calories ?? this.calories,
      points: points ?? this.points,
      splits: splits ?? this.splits,
      lastAccuracy: lastAccuracy ?? this.lastAccuracy,
    );
  }

  Map<String, dynamic> toJson() => {
        'client_uuid': clientUuid,
        'type': type.name,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'is_tracking': isTracking,
        'is_paused': isPaused,
        'distance_meters': distanceMeters,
        'moving_time_seconds': movingTimeSeconds,
        'elapsed_time_seconds': elapsedTimeSeconds,
        'current_speed_mps': currentSpeedMps,
        'max_speed_mps': maxSpeedMps,
        'current_pace_seconds_per_km': currentPaceSecondsPerKm,
        'avg_pace_seconds_per_km': avgPaceSecondsPerKm,
        'elevation_gain_meters': elevationGainMeters,
        'calories': calories,
        'points': points.map((p) => p.toJson()).toList(),
        'splits': splits.map((s) => s.toJson()).toList(),
        'last_accuracy': lastAccuracy,
      };

  factory TrackingSession.fromJson(Map<String, dynamic> json) {
    return TrackingSession(
      clientUuid: json['client_uuid'] as String,
      type: ActivityType.fromString(json['type'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      isTracking: json['is_tracking'] as bool? ?? false,
      isPaused: json['is_paused'] as bool? ?? false,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
      movingTimeSeconds: (json['moving_time_seconds'] as num?)?.toInt() ?? 0,
      elapsedTimeSeconds: (json['elapsed_time_seconds'] as num?)?.toInt() ?? 0,
      currentSpeedMps: (json['current_speed_mps'] as num?)?.toDouble() ?? 0.0,
      maxSpeedMps: (json['max_speed_mps'] as num?)?.toDouble() ?? 0.0,
      currentPaceSecondsPerKm:
          (json['current_pace_seconds_per_km'] as num?)?.toInt() ?? 0,
      avgPaceSecondsPerKm:
          (json['avg_pace_seconds_per_km'] as num?)?.toInt() ?? 0,
      elevationGainMeters:
          (json['elevation_gain_meters'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => LocationPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      splits: (json['splits'] as List<dynamic>?)
              ?.map((e) => ActivitySplit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastAccuracy: (json['last_accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
