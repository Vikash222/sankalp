import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// MethodChannel & EventChannel bridge connecting Flutter with native Android DetoxPlugin.
class DetoxNativeBridge {
  static const MethodChannel _methodChannel = MethodChannel('com.arclife.app/detox');
  static const EventChannel _eventChannel = EventChannel('com.arclife.app/detox_events');

  Stream<Map<String, dynamic>>? _eventStream;

  /// Check whether Android Usage Access permission has been granted.
  Future<bool> hasUsageStatsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool result = await _methodChannel.invokeMethod('hasUsageStatsPermission');
      return result;
    } catch (_) {
      return false;
    }
  }

  /// Launch Android Usage Access settings page.
  Future<void> requestUsageStatsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _methodChannel.invokeMethod('requestUsageStatsPermission');
    } catch (e) {
      debugPrint('Error requesting usage stats permission: $e');
    }
  }

  /// Check whether Do Not Disturb (Notification Policy) access is granted.
  Future<bool> hasDndPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final bool result = await _methodChannel.invokeMethod('hasDndPermission');
      return result;
    } catch (_) {
      return false;
    }
  }

  /// Launch Android Notification Policy Access settings page.
  Future<void> requestDndPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _methodChannel.invokeMethod('requestDndPermission');
    } catch (e) {
      debugPrint('Error requesting DND permission: $e');
    }
  }

  /// Toggle Do Not Disturb mode on or off.
  Future<void> setDndMode(bool enabled) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _methodChannel.invokeMethod('setDndMode', {'enabled': enabled});
    } catch (e) {
      debugPrint('Error setting DND mode: $e');
    }
  }

  /// Start native focus monitor service with list of blocked package IDs.
  Future<void> startFocusSession({
    required List<String> blockedPackages,
    required int durationMinutes,
    bool enableDnd = true,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _methodChannel.invokeMethod('startFocusSession', {
        'blocked_packages': blockedPackages,
        'duration_minutes': durationMinutes,
        'enable_dnd': enableDnd,
      });
    } catch (e) {
      debugPrint('Error starting focus session: $e');
    }
  }

  /// Stop native focus monitor service early.
  Future<void> stopFocusSession() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _methodChannel.invokeMethod('stopFocusSession');
    } catch (e) {
      debugPrint('Error stopping focus session: $e');
    }
  }

  /// Retrieve list of installed user applications for blocking configuration.
  Future<List<Map<String, dynamic>>> getInstalledUserApps() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return [
        {'package_name': 'com.instagram.android', 'app_name': 'Instagram', 'is_system': false},
        {'package_name': 'com.google.android.youtube', 'app_name': 'YouTube', 'is_system': false},
        {'package_name': 'com.reddit.frontpage', 'app_name': 'Reddit', 'is_system': false},
        {'package_name': 'com.twitter.android', 'app_name': 'X (Twitter)', 'is_system': false},
        {'package_name': 'com.snapchat.android', 'app_name': 'Snapchat', 'is_system': false},
      ];
    }

    try {
      final List<dynamic>? result = await _methodChannel.invokeMethod('getInstalledUserApps');
      if (result == null) return [];
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error fetching installed apps: $e');
      return [];
    }
  }

  /// Stream of native detox events (app blocked triggers, session ended callbacks).
  Stream<Map<String, dynamic>> get eventStream {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Stream.empty();
    }
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _eventStream!;
  }
}
