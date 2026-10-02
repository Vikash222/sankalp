/// Supported workout activity types with domain-specific physics parameters.
enum ActivityType {
  run,
  walk,
  cycle,
  hike;

  String get displayName {
    switch (this) {
      case ActivityType.run:
        return 'Running';
      case ActivityType.walk:
        return 'Walking';
      case ActivityType.cycle:
        return 'Cycling';
      case ActivityType.hike:
        return 'Hiking';
    }
  }

  String get displayNameHi {
    switch (this) {
      case ActivityType.run:
        return 'दौड़ना';
      case ActivityType.walk:
        return 'टहलना';
      case ActivityType.cycle:
        return 'साइकिल चलाना';
      case ActivityType.hike:
        return 'हाइकिंग';
    }
  }

  /// Maximum realistic human speed in meters per second for outlier rejection.
  /// Anything above this is considered GPS drift, vehicle riding, or spoofing.
  double get maxRealisticSpeedMps {
    switch (this) {
      case ActivityType.run:
        return 6.94; // 25.0 km/h (Usain Bolt peak is ~12 m/s, marathon elite ~5.7 m/s)
      case ActivityType.walk:
        return 3.33; // 12.0 km/h (Olympic race walk peak ~4.1 m/s)
      case ActivityType.cycle:
        return 16.67; // 60.0 km/h
      case ActivityType.hike:
        return 3.61; // 13.0 km/h
    }
  }

  /// Minimum speed in m/s below which the user is considered stationary for auto-pause.
  double get autoPauseThresholdMps {
    switch (this) {
      case ActivityType.run:
        return 0.60; // ~2.16 km/h
      case ActivityType.walk:
        return 0.45; // ~1.62 km/h
      case ActivityType.cycle:
        return 1.20; // ~4.32 km/h
      case ActivityType.hike:
        return 0.35; // ~1.26 km/h
    }
  }

  /// Base MET (Metabolic Equivalent of Task) value for general moderate intensity.
  double get defaultMet {
    switch (this) {
      case ActivityType.run:
        return 9.8;
      case ActivityType.walk:
        return 3.5;
      case ActivityType.cycle:
        return 6.8;
      case ActivityType.hike:
        return 6.0;
    }
  }

  static ActivityType fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'run':
      case 'running':
        return ActivityType.run;
      case 'walk':
      case 'walking':
        return ActivityType.walk;
      case 'cycle':
      case 'cycling':
      case 'biking':
        return ActivityType.cycle;
      case 'hike':
      case 'hiking':
        return ActivityType.hike;
      default:
        return ActivityType.run;
    }
  }
}
