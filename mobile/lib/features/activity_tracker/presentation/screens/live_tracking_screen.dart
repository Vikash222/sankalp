import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../domain/entities/activity_type.dart';
import '../../data/datasources/activity_native_bridge.dart';
import '../providers/tracking_notifier.dart';
import '../widgets/location_permission_disclosure_dialog.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final ActivityType activityType;

  const LiveTrackingScreen({
    super.key,
    this.activityType = ActivityType.run,
  });

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  final ActivityNativeBridge _bridge = ActivityNativeBridge();

  bool _keepAwake = true;
  bool _audioCuesEnabled = true;
  double _stopHoldProgress = 0.0;
  Timer? _stopHoldTimer;

  bool _hasLocationPermission = false;
  bool _isGpsEnabled = true;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _checkAndInitTracking();
  }

  @override
  void dispose() {
    _stopHoldTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _checkAndInitTracking() async {
    setState(() => _isCheckingPermission = true);

    final hasPerm = await _bridge.hasLocationPermission();
    final gpsOn = await _bridge.isGpsEnabled();

    if (!mounted) return;

    setState(() {
      _hasLocationPermission = hasPerm;
      _isGpsEnabled = gpsOn;
      _isCheckingPermission = false;
    });

    if (!hasPerm) {
      // Show Google Play compliant disclosure before prompting
      _promptLocationDisclosure();
    } else {
      _startOrResumeWorkout();
    }
  }

  void _promptLocationDisclosure() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationPermissionDisclosureDialog(
        isHindi: false,
        onAccepted: () async {
          Navigator.of(ctx).pop();
          final granted = await _bridge.requestLocationPermission();
          await _bridge.requestNotificationPermission();

          if (!mounted) return;
          setState(() => _hasLocationPermission = granted);

          if (granted) {
            _startOrResumeWorkout();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Location permission is required for accurate GPS tracking.',
                ),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => _bridge.openAppSettings(),
                ),
              ),
            );
          }
        },
        onDeclined: () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking cannot start without location permission.'),
            ),
          );
        },
      ),
    );
  }

  void _startOrResumeWorkout() {
    final session = ref.read(trackingNotifierProvider);
    if (!session.isTracking) {
      ref.read(trackingNotifierProvider.notifier).startTracking(widget.activityType);
    }
  }

  void _onStopHoldStart() {
    _stopHoldProgress = 0.0;
    _stopHoldTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _stopHoldProgress += 0.05; // Reaches 1.0 in 1 second
        if (_stopHoldProgress >= 1.0) {
          timer.cancel();
          _stopSession();
        }
      });
    });
  }

  void _onStopHoldEnd() {
    _stopHoldTimer?.cancel();
    setState(() => _stopHoldProgress = 0.0);
  }

  Future<void> _stopSession() async {
    final finishedSession = await ref.read(trackingNotifierProvider.notifier).stopTracking();
    if (mounted) {
      context.pushReplacement('/tracker/summary', extra: finishedSession);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(trackingNotifierProvider);
    final isPaused = session.isPaused;

    final distanceKm = session.formattedDistanceKm;
    final paceStr = session.formattedAvgPace;
    final durationStr = session.formattedMovingTime;
    final calories = session.calories.toString();
    final elevation = session.elevationGainMeters.toStringAsFixed(0);

    // Extract live coordinates from GPS session
    final routePoints = session.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final centerPoint = routePoints.isNotEmpty
        ? routePoints.last
        : const LatLng(28.6139, 77.2090);

    return Scaffold(
      appBar: SankalpAppBar(
        title: 'Live ${widget.activityType.displayName}',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              _audioCuesEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _audioCuesEnabled ? SankalpTheme.brandYellow : Colors.grey,
            ),
            tooltip: 'Audio Cues',
            onPressed: () {
              setState(() => _audioCuesEnabled = !_audioCuesEnabled);
            },
          ),
          IconButton(
            icon: Icon(
              _keepAwake ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              color: _keepAwake ? SankalpTheme.brandYellow : Colors.grey,
            ),
            tooltip: 'Screen Keep-Awake',
            onPressed: () {
              setState(() {
                _keepAwake = !_keepAwake;
                if (_keepAwake) {
                  WakelockPlus.enable();
                } else {
                  WakelockPlus.disable();
                }
              });
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap with route polyline
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'app.sankalp.mobile',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5.0,
                      color: const Color(0xFFFFC727),
                    ),
                  ],
                ),
              if (routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routePoints.last,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Permission warning banner if missing
          if (!_isCheckingPermission && !_hasLocationPermission)
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber[900]?.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Location access is required for GPS tracking.',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: _promptLocationDisclosure,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text('Allow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // GPS Provider disabled banner
          if (!_isCheckingPermission && _hasLocationPermission && !_isGpsEnabled)
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[800]?.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_off_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Device GPS is turned off.',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _bridge.openLocationSettings(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text('Enable GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Telemetry Dashboard Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Distance & Time Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(distanceKm, 'Distance (km)'),
                      Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                      _buildMetric(durationStr, 'Duration'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Secondary Sub-Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSubMetric('$paceStr /km', 'Avg Pace'),
                      _buildSubMetric('$calories kcal', 'Calories'),
                      _buildSubMetric('$elevation m', 'Elevation'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Controls Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pause / Resume Button
                      ElevatedButton(
                        onPressed: () {
                          if (isPaused) {
                            ref.read(trackingNotifierProvider.notifier).resumeTracking();
                          } else {
                            ref.read(trackingNotifierProvider.notifier).pauseTracking();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaused ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18),
                        ),
                        child: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 32,
                        ),
                      ),

                      // Hold to Stop Button
                      GestureDetector(
                        onTapDown: (_) => _onStopHoldStart(),
                        onTapUp: (_) => _onStopHoldEnd(),
                        onTapCancel: () => _onStopHoldEnd(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: _stopHoldProgress,
                                strokeWidth: 4,
                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stop_rounded, color: Colors.white, size: 28),
                                  Text(
                                    'HOLD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSubMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
