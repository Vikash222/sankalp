import '../entities/activity_type.dart';

enum AutoPauseAction {
  none,
  pause,
  resume,
}

/// Detects stationary status and handles auto-pause/auto-resume with hysteresis.
class AutoPauseDetector {
  final int consecutiveSamplesRequired;
  int _consecutiveStationaryCount = 0;
  int _consecutiveMovingCount = 0;
  bool _isAutoPaused = false;

  AutoPauseDetector({this.consecutiveSamplesRequired = 3});

  bool get isAutoPaused => _isAutoPaused;

  void reset() {
    _consecutiveStationaryCount = 0;
    _consecutiveMovingCount = 0;
    _isAutoPaused = false;
  }

  AutoPauseAction evaluateSpeed({
    required double currentSpeedMps,
    required ActivityType activityType,
    required bool isCurrentlyTracking,
    required bool isManuallyPaused,
  }) {
    if (!isCurrentlyTracking || isManuallyPaused) {
      return AutoPauseAction.none;
    }

    final threshold = activityType.autoPauseThresholdMps;
    final resumeThreshold = threshold * 1.3; // 30% hysteresis

    if (!_isAutoPaused) {
      if (currentSpeedMps < threshold) {
        _consecutiveStationaryCount++;
        _consecutiveMovingCount = 0;
        if (_consecutiveStationaryCount >= consecutiveSamplesRequired) {
          _isAutoPaused = true;
          return AutoPauseAction.pause;
        }
      } else {
        _consecutiveStationaryCount = 0;
      }
    } else {
      // Currently auto-paused
      if (currentSpeedMps >= resumeThreshold) {
        _consecutiveMovingCount++;
        _consecutiveStationaryCount = 0;
        if (_consecutiveMovingCount >= 2) {
          _isAutoPaused = false;
          return AutoPauseAction.resume;
        }
      } else {
        _consecutiveMovingCount = 0;
      }
    }

    return AutoPauseAction.none;
  }
}
