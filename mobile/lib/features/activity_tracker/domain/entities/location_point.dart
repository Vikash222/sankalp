import 'package:latlong2/latlong.dart';

/// Immutable domain entity representing a single recorded GPS point.
class LocationPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy; // In meters
  final double speed; // In meters/second
  final double bearing; // Degrees (0..360)
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    this.accuracy = 0.0,
    this.speed = 0.0,
    this.bearing = 0.0,
    required this.timestamp,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'accuracy': accuracy,
        'speed': speed,
        'bearing': bearing,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      bearing: (json['bearing'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num).toInt(),
      ),
    );
  }

  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? bearing,
    DateTime? timestamp,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'LocationPoint(lat: $latitude, lng: $longitude, acc: $accuracy, spd: $speed, alt: $altitude)';
}
