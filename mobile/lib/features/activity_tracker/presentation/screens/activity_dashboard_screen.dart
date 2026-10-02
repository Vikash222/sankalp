import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../data/datasources/activity_native_bridge.dart';
import '../../data/datasources/workout_storage.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/tracking_session.dart';
import '../widgets/location_permission_disclosure_dialog.dart';

class ActivityDashboardScreen extends ConsumerStatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  ConsumerState<ActivityDashboardScreen> createState() => _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState extends ConsumerState<ActivityDashboardScreen>
    with WidgetsBindingObserver {
  final ActivityNativeBridge _bridge = ActivityNativeBridge();
  ActivityType _selectedType = ActivityType.run;

  bool _hasLocationPermission = false;
  bool _isGpsEnabled = true;
  bool _isCheckingStatus = true;

  List<TrackingSession> _recentWorkouts = [];
  WeeklyWorkoutStats _weeklyStats = const WeeklyWorkoutStats(
    distanceKm: 0.0,
    durationSeconds: 0,
    calories: 0,
    sessionCount: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationAndGps();
    _loadWorkouts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationAndGps();
      _loadWorkouts();
    }
  }

  Future<void> _loadWorkouts() async {
    try {
      final storage = ref.read(workoutStorageProvider);
      final workouts = await storage.getWorkouts();
      final stats = await storage.getWeeklyStats();
      if (!mounted) return;
      setState(() {
        _recentWorkouts = workouts.take(3).toList();
        _weeklyStats = stats;
      });
    } catch (_) {}
  }

  Future<void> _checkLocationAndGps() async {
    setState(() => _isCheckingStatus = true);
    final hasPerm = await _bridge.hasLocationPermission();
    final gpsOn = await _bridge.isGpsEnabled();

    if (!mounted) return;
    setState(() {
      _hasLocationPermission = hasPerm;
      _isGpsEnabled = gpsOn;
      _isCheckingStatus = false;
    });
  }

  void _requestLocationWithDisclosure({VoidCallback? onGranted}) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                    SizedBox(width: 8),
                    Text('Location access enabled. GPS telemetry ready!'),
                  ],
                ),
                backgroundColor: Colors.black,
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (onGranted != null) {
              onGranted();
            }
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
        },
      ),
    );
  }

  void _startWorkoutSession() {
    if (!_hasLocationPermission) {
      _requestLocationWithDisclosure(onGranted: () {
        if (mounted) {
          context.push('/tracker/live', extra: _selectedType);
        }
      });
    } else {
      context.push('/tracker/live', extra: _selectedType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Activity Tracker',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location & GPS Telemetry Status Card
            _buildLocationStatusCard(),
            const SizedBox(height: 16),

            // Hero Start Tracking Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC727),
                    Color(0xFFF7B500),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC727).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ActivityType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedType = type);
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.black.withValues(alpha: 0.08),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton.icon(
                    onPressed: _startWorkoutSession,
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Start ${_selectedType.displayName} Session',
                        maxLines: 1,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color(0xFFFFC727),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Free OpenStreetMap • GPS telemetry • Lock-screen controls',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2C)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Stats Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THIS WEEK\'S DISCIPLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol(_weeklyStats.formattedDistance, 'Distance'),
                      _buildMetricCol(_weeklyStats.formattedDuration, 'Duration'),
                      _buildMetricCol(_weeklyStats.formattedCalories, 'Calories'),
                      _buildMetricCol(_weeklyStats.formattedSessions, 'Sessions'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Workouts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Workouts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/tracker/history'),
                  child: const Text(
                    'View All History',
                    style: TextStyle(
                      color: Color(0xFF946A00),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_recentWorkouts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_run_rounded, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text(
                        'No Workouts Recorded Yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start your first running or walking session to track live GPS routes and stats.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recentWorkouts.map((workout) => _buildWorkoutSessionTile(workout)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    if (_isCheckingStatus) {
      return const SizedBox.shrink();
    }

    if (!_hasLocationPermission) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_searching_rounded, color: Colors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Access Required',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Enable GPS location access to track real-time routes, pace, and Haversine distance.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _requestLocationWithDisclosure(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: SankalpTheme.brandYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Grant Permission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _bridge.openAppSettings(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: const Text('Device Settings', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (!_isGpsEnabled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.deepOrange, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Device GPS is Switched Off', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Turn on location services in device settings for GPS tracking.', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _bridge.openLocationSettings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Turn On', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.satellite_alt_rounded, color: Colors.green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'GPS Telemetry Calibrated • High-accuracy route mapping ready',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87),
            ),
          ),
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWorkoutSessionTile(TrackingSession session) {
    final typeName = session.type.displayName;
    final dateStr = DateFormat('MMM d, h:mm a').format(session.startedAt);
    final icon = switch (session.type) {
      ActivityType.run => Icons.directions_run_rounded,
      ActivityType.walk => Icons.directions_walk_rounded,
      ActivityType.cycle => Icons.directions_bike_rounded,
      ActivityType.hike => Icons.terrain_rounded,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () => context.push('/tracker/summary', extra: session),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
          ),
          child: Icon(icon, color: const Color(0xFF946A00), size: 24),
        ),
        title: Text(typeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          '$dateStr\n${session.formattedMovingTime} • ${session.formattedAvgPace} /km',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        isThreeLine: true,
        trailing: Text(
          '${session.formattedDistanceKm} km',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
