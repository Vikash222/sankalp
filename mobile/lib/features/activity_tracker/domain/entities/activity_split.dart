/// Represents an individual 1-kilometer or 1-mile segment breakdown.
class ActivitySplit {
  final int splitIndex;
  final double distanceMeters;
  final int durationSeconds;
  final int paceSecondsPerKm;
  final double elevationChangeMeters;

  const ActivitySplit({
    required this.splitIndex,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceSecondsPerKm,
    this.elevationChangeMeters = 0.0,
  });

  String get formattedPace {
    if (paceSecondsPerKm <= 0 || paceSecondsPerKm > 3600) return '--:--';
    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = paceSecondsPerKm % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'split_index': splitIndex,
        'distance_meters': distanceMeters,
        'duration_seconds': durationSeconds,
        'pace_seconds_per_km': paceSecondsPerKm,
        'elevation_change_meters': elevationChangeMeters,
      };

  factory ActivitySplit.fromJson(Map<String, dynamic> json) {
    return ActivitySplit(
      splitIndex: (json['split_index'] as num).toInt(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      paceSecondsPerKm: (json['pace_seconds_per_km'] as num).toInt(),
      elevationChangeMeters:
          (json['elevation_change_meters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
