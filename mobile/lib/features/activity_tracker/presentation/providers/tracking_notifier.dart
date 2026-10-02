import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/activity_native_bridge.dart';
import '../../data/datasources/crash_recovery_storage.dart';
import '../../data/datasources/workout_storage.dart';
import '../../../../core/sync/offline_sync_engine.dart';
import '../../../gamification/presentation/providers/gamification_notifier.dart';
import '../../domain/entities/activity_split.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/tracking_session.dart';
import '../../domain/services/auto_pause_detector.dart';
import '../../domain/services/location_filter_service.dart';
import '../../domain/services/met_calorie_calculator.dart';
import '../../domain/services/pace_split_calculator.dart';

final activityNativeBridgeProvider = Provider((ref) => ActivityNativeBridge());
final crashRecoveryStorageProvider = Provider((ref) => CrashRecoveryStorage());

final trackingNotifierProvider =
    NotifierProvider<TrackingNotifier, TrackingSession>(TrackingNotifier.new);

class TrackingNotifier extends Notifier<TrackingSession> {
  late final ActivityNativeBridge nativeBridge;
  late final CrashRecoveryStorage crashStorage;

  final LocationFilterService _filterService = LocationFilterService();
  final AutoPauseDetector _autoPauseDetector = AutoPauseDetector();
  final PaceSplitCalculator _paceCalculator = PaceSplitCalculator();

  StreamSubscription<LocationPoint>? _locationSub;
  StreamSubscription<Map<String, dynamic>>? _statusSub;
  Timer? _tickerTimer;

  LocationPoint? _lastAcceptedPoint;
  double _userWeightKg = 70.0;

  @override
  TrackingSession build() {
    nativeBridge = ref.watch(activityNativeBridgeProvider);
    crashStorage = ref.watch(crashRecoveryStorageProvider);

    _initStatusListener();

    ref.onDispose(() {
      _tickerTimer?.cancel();
      _locationSub?.cancel();
      _statusSub?.cancel();
    });

    return TrackingSession(
      clientUuid: const Uuid().v4(),
      type: ActivityType.run,
      startedAt: DateTime.now(),
    );
  }

  void setUserWeight(double weightKg) {
    _userWeightKg = weightKg;
  }

  void _initStatusListener() {
    _statusSub?.cancel();
    _statusSub = nativeBridge.statusStream.listen((event) {
      final type = event['type'] as String?;
      if (type == 'status') {
        final val = event['value'] as String?;
        if (val == 'paused' && !state.isPaused) {
          pauseTracking(isAuto: false);
        } else if (val == 'tracking' && state.isPaused) {
          resumeTracking(isAuto: false);
        } else if (val == 'stopped' && state.isTracking) {
          stopTracking();
        }
      }
    });
  }

  /// Checks local disk for any unfinalized session left behind by a crash.
  Future<TrackingSession?> checkCrashRecovery() async {
    final recovered = await crashStorage.loadActiveSession();
    return recovered;
  }

  /// Restores a recovered workout session and resumes tracking.
  Future<void> restoreSession(TrackingSession recovered) async {
    _filterService.reset();
    _autoPauseDetector.reset();
    _paceCalculator.reset();
    _lastAcceptedPoint = recovered.points.isNotEmpty ? recovered.points.last : null;

    state = recovered.copyWith(isTracking: true, isPaused: false);

    await nativeBridge.startTracking(
      activityType: recovered.type,
      title: 'Sankalp ${recovered.type.displayName}',
    );

    _startLocationSubscription();
    _startTicker();
  }

  /// Starts a fresh workout tracking session.
  Future<void> startTracking(ActivityType activityType) async {
    final newSession = TrackingSession(
      clientUuid: const Uuid().v4(),
      type: activityType,
      startedAt: DateTime.now(),
      isTracking: true,
      isPaused: false,
    );

    _filterService.reset();
    _autoPauseDetector.reset();
    _paceCalculator.reset();
    _lastAcceptedPoint = null;

    state = newSession;

    await nativeBridge.startTracking(
      activityType: activityType,
      title: 'Sankalp ${activityType.displayName}',
    );

    _startLocationSubscription();
    _startTicker();
    await crashStorage.saveActiveSession(state);
  }

  void _startLocationSubscription() {
    _locationSub?.cancel();
    _locationSub = nativeBridge.locationStream.listen((rawPoint) {
      _processLocationPoint(rawPoint);
    });
  }

  void _processLocationPoint(LocationPoint rawPoint) {
    if (!state.isTracking) return;

    // Evaluate auto-pause
    final autoPauseAction = _autoPauseDetector.evaluateSpeed(
      currentSpeedMps: rawPoint.speed,
      activityType: state.type,
      isCurrentlyTracking: state.isTracking,
      isManuallyPaused: state.isPaused,
    );

    if (autoPauseAction == AutoPauseAction.pause) {
      pauseTracking(isAuto: true);
      return;
    } else if (autoPauseAction == AutoPauseAction.resume) {
      resumeTracking(isAuto: true);
    }

    if (state.isPaused) return;

    // Filter incoming GPS reading
    final filterResult = _filterService.evaluatePoint(
      rawPoint: rawPoint,
      previousPoint: _lastAcceptedPoint,
      activityType: state.type,
    );

    if (!filterResult.isAccepted || filterResult.smoothedPoint == null) {
      state = state.copyWith(lastAccuracy: rawPoint.accuracy);
      return;
    }

    final acceptedPoint = filterResult.smoothedPoint!;
    _lastAcceptedPoint = acceptedPoint;

    final updatedDistance = state.distanceMeters + filterResult.segmentDistanceMeters;
    final updatedElevation = state.elevationGainMeters + filterResult.elevationGainMeters;

    final currentPace = _paceCalculator.calculateCurrentPaceSecondsPerKm(acceptedPoint);
    final avgPace = _paceCalculator.calculateAveragePaceSecondsPerKm(
      totalDistanceMeters: updatedDistance,
      movingTimeSeconds: state.movingTimeSeconds,
    );

    final maxSpeed = acceptedPoint.speed > state.maxSpeedMps
        ? acceptedPoint.speed
        : state.maxSpeedMps;

    // Check for 1km split completion
    final newSplit = _paceCalculator.checkAndRecordSplit(
      totalDistanceMeters: updatedDistance,
      movingTimeSeconds: state.movingTimeSeconds,
      currentAltitude: acceptedPoint.altitude,
    );

    final updatedSplits = List<ActivitySplit>.from(state.splits);
    if (newSplit != null) {
      updatedSplits.add(newSplit);
    }

    final updatedPoints = List<LocationPoint>.from(state.points)..add(acceptedPoint);

    final estimatedCalories = MetCalorieCalculator.calculateCalories(
      activityType: state.type,
      speedMps: acceptedPoint.speed,
      durationSeconds: state.movingTimeSeconds,
      userWeightKg: _userWeightKg,
    ).round();

    state = state.copyWith(
      distanceMeters: updatedDistance,
      elevationGainMeters: updatedElevation,
      currentSpeedMps: acceptedPoint.speed,
      maxSpeedMps: maxSpeed,
      currentPaceSecondsPerKm: currentPace,
      avgPaceSecondsPerKm: avgPace,
      calories: estimatedCalories,
      points: updatedPoints,
      splits: updatedSplits,
      lastAccuracy: acceptedPoint.accuracy,
    );

    // Push stats to native notification
    nativeBridge.updateNotificationStats(
      distanceM: updatedDistance,
      elapsedSec: state.elapsedTimeSeconds,
      paceStr: state.formattedCurrentPace,
    );

    // Save to disk for crash resilience
    crashStorage.saveActiveSession(state);
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isTracking) return;

      final newElapsed = state.elapsedTimeSeconds + 1;
      final newMoving = state.isPaused
          ? state.movingTimeSeconds
          : state.movingTimeSeconds + 1;

      state = state.copyWith(
        elapsedTimeSeconds: newElapsed,
        movingTimeSeconds: newMoving,
      );
    });
  }

  Future<void> pauseTracking({bool isAuto = false}) async {
    if (!state.isTracking || state.isPaused) return;

    state = state.copyWith(isPaused: true);
    await nativeBridge.pauseTracking();
    await crashStorage.saveActiveSession(state);
  }

  Future<void> resumeTracking({bool isAuto = false}) async {
    if (!state.isTracking || !state.isPaused) return;

    state = state.copyWith(isPaused: false);
    await nativeBridge.resumeTracking();
    await crashStorage.saveActiveSession(state);
  }

  Future<TrackingSession> stopTracking() async {
    _tickerTimer?.cancel();
    _locationSub?.cancel();

    await nativeBridge.stopTracking();

    final finalAlt = state.points.isNotEmpty ? state.points.last.altitude : 0.0;
    final finalSplit = _paceCalculator.finalizeLastPartialSplit(
      totalDistanceMeters: state.distanceMeters,
      movingTimeSeconds: state.movingTimeSeconds,
      currentAltitude: finalAlt,
    );

    final finalSplits = List<ActivitySplit>.from(state.splits);
    if (finalSplit != null) {
      finalSplits.add(finalSplit);
    }

    final finalized = state.copyWith(
      endedAt: DateTime.now(),
      isTracking: false,
      isPaused: false,
      splits: finalSplits,
    );

    state = finalized;
    await crashStorage.clearActiveSession();

    // Persist workout locally
    try {
      await ref.read(workoutStorageProvider).saveWorkout(finalized);
    } catch (_) {}

    // Enqueue workout for offline/online backend sync
    try {
      await ref.read(offlineSyncEngineProvider).enqueueWorkout(finalized.toJson());
    } catch (_) {}

    // Award bonus XP for completing physical workout session
    try {
      await ref.read(gamificationNotifierProvider.notifier).addXp(50);
    } catch (_) {}

    return finalized;
  }

  Future<void> discardTracking() async {
    _tickerTimer?.cancel();
    _locationSub?.cancel();
    await nativeBridge.stopTracking();
    await crashStorage.clearActiveSession();

    state = TrackingSession(
      clientUuid: const Uuid().v4(),
      type: state.type,
      startedAt: DateTime.now(),
    );
  }
}
