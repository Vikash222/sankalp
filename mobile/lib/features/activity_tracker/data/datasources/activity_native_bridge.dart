import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/location_point.dart';

/// Dart wrapper communicating across MethodChannel and EventChannel with
/// native Kotlin LocationTrackingService with permission negotiation.
class ActivityNativeBridge {
  static const MethodChannel _methodChannel =
      MethodChannel('com.arclife.app/activity_tracker');
  static const EventChannel _locationEventChannel =
      EventChannel('com.arclife.app/location_stream');
  static const EventChannel _statusEventChannel =
      EventChannel('com.arclife.app/status_stream');

  Stream<LocationPoint>? _locationStream;
  Stream<Map<String, dynamic>>? _statusStream;

  /// Checks whether fine location runtime permission has been granted.
  Future<bool> hasLocationPermission() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('hasLocationPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Triggers native Android system permission prompt for ACCESS_FINE_LOCATION.
  Future<bool> requestLocationPermission() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('requestLocationPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Checks whether Android 13+ POST_NOTIFICATIONS permission has been granted.
  Future<bool> hasNotificationPermission() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('hasNotificationPermission');
      return result ?? true;
    } on PlatformException {
      return true;
    }
  }

  /// Triggers notification permission prompt for lock-screen workout controls.
  Future<bool> requestNotificationPermission() async {
    try {
      final result = await _methodChannel
          .invokeMethod<bool>('requestNotificationPermission');
      return result ?? true;
    } on PlatformException {
      return true;
    }
  }

  /// Launches Android Application Info settings screen for user to grant permanently denied permissions.
  Future<void> openAppSettings() async {
    try {
      await _methodChannel.invokeMethod('openAppSettings');
    } on PlatformException {
      // Ignored
    }
  }

  /// Launches Android Location Settings screen if GPS provider is disabled.
  Future<void> openLocationSettings() async {
    try {
      await _methodChannel.invokeMethod('openLocationSettings');
    } on PlatformException {
      // Ignored
    }
  }

  /// Starts the native Android location foreground service.
  Future<bool> startTracking({
    required ActivityType activityType,
    required String title,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('startTracking', {
        'activityType': activityType.name,
        'title': title,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to start native tracking service: ${e.message}');
    }
  }

  /// Pauses location updates in the foreground service.
  Future<bool> pauseTracking() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('pauseTracking');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to pause tracking: ${e.message}');
    }
  }

  /// Resumes location updates in the foreground service.
  Future<bool> resumeTracking() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('resumeTracking');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to resume tracking: ${e.message}');
    }
  }

  /// Stops and tears down the native foreground service.
  Future<bool> stopTracking() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('stopTracking');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop tracking: ${e.message}');
    }
  }

  /// Pushes current live metrics into the native Android ongoing notification.
  Future<void> updateNotificationStats({
    required double distanceM,
    required int elapsedSec,
    required String paceStr,
  }) async {
    try {
      await _methodChannel.invokeMethod('updateNotificationStats', {
        'distanceM': distanceM,
        'elapsedSec': elapsedSec,
        'paceStr': paceStr,
      });
    } on PlatformException {
      // Ignored non-critical UI update
    }
  }

  /// Queries whether system GPS provider is currently enabled.
  Future<bool> isGpsEnabled() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isGpsEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Queries whether foreground tracking is currently running.
  Future<bool> isTrackingRunning() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('isTrackingRunning');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stream of raw LocationPoint records emitted by Android LocationManager.
  Stream<LocationPoint> get locationStream {
    _locationStream ??= _locationEventChannel
        .receiveBroadcastStream()
        .map((event) {
          final map = Map<String, dynamic>.from(event as Map);
          return LocationPoint(
            latitude: (map['latitude'] as num).toDouble(),
            longitude: (map['longitude'] as num).toDouble(),
            altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
            accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
            speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
            bearing: (map['bearing'] as num?)?.toDouble() ?? 0.0,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              (map['timestamp'] as num).toInt(),
            ),
          );
        });
    return _locationStream!;
  }

  /// Stream of lifecycle status events ("tracking", "paused", "stopped", GPS events).
  Stream<Map<String, dynamic>> get statusStream {
    _statusStream ??= _statusEventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _statusStream!;
  }
}
