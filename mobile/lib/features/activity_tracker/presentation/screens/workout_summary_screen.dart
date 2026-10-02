import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/tracking_session.dart';
import '../../domain/services/gpx_generator.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final TrackingSession? session;

  const WorkoutSummaryScreen({super.key, this.session});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  bool _hidePrivacyZones = true;
  bool _isPrivate = true;
  late final TrackingSession _effectiveSession;

  @override
  void initState() {
    super.initState();
    _effectiveSession = widget.session ?? _createEmptySession();
  }

  TrackingSession _createEmptySession() {
    final now = DateTime.now();
    return TrackingSession(
      clientUuid: 'fresh-session',
      type: ActivityType.run,
      startedAt: now,
      endedAt: now,
      distanceMeters: 0.0,
      movingTimeSeconds: 0,
      elapsedTimeSeconds: 0,
      currentSpeedMps: 0.0,
      maxSpeedMps: 0.0,
      avgPaceSecondsPerKm: 0,
      currentPaceSecondsPerKm: 0,
      elevationGainMeters: 0.0,
      calories: 0,
      points: const [],
      splits: const [],
    );
  }

  void _exportGpx() {
    final gpxXml = GpxGenerator.generateGpx(
      _effectiveSession,
      hidePrivacyZones: _hidePrivacyZones,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Export GPX File',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Standard GPX 1.1 format compatible with Strava, Garmin, and open-source fitness tools.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    gpxXml,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: gpxXml));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GPX file contents copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 20),
                label: const Text('Copy GPX to Clipboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SankalpTheme.brandYellow,
                  foregroundColor: SankalpTheme.brandBlack,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareCard() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SankalpTheme.brandYellow,
                ),
                child: const Center(
                  child: SankalpRoundLogo(size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SANKALP DISCIPLINE BADGE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_effectiveSession.formattedDistanceKm} KM COMPLETED',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Pace: ${_effectiveSession.formattedAvgPace} /km • Duration: ${_effectiveSession.formattedMovingTime}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SankalpTheme.brandYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Color(0xFF946A00), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '+50 Discipline XP • Habit Logged',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Achievement badge shared successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Share to Status / Community'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _effectiveSession.points.isNotEmpty
        ? _effectiveSession.points.map((p) => p.toLatLng()).toList()
        : [const LatLng(28.6139, 77.2090), const LatLng(28.6250, 77.2230)];

    return Scaffold(
      appBar: SankalpAppBar(
        title: 'Workout Summary',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Card',
            onPressed: _showShareCard,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export GPX',
            onPressed: _exportGpx,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC727), Color(0xFFF7B500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC727).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _effectiveSession.type.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFC727),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        _effectiveSession.formattedMovingTime,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _effectiveSession.formattedDistanceKm,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'kilometers',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech_rounded, size: 20, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          '+50 Discipline XP • 21-Day Habit auto-completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Map Route Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: routePoints.first,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.sankalp.mobile',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.5,
                          color: const Color(0xFFFFC727),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Start point marker
                        Marker(
                          point: routePoints.first,
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        // Finish point marker
                        Marker(
                          point: routePoints.last,
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            child: const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Grid (Avg Pace, Calories, Elevation, Max Speed)
            Row(
              children: [
                Expanded(child: _buildMetricTile('Avg Pace', '${_effectiveSession.formattedAvgPace} /km', Icons.speed_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile('Calories', '${_effectiveSession.calories} kcal', Icons.local_fire_department_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricTile('Elevation Gain', '${_effectiveSession.elevationGainMeters.toStringAsFixed(0)} m', Icons.terrain_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile('Max Speed', '${(_effectiveSession.maxSpeedMps * 3.6).toStringAsFixed(1)} km/h', Icons.trending_up_rounded)),
              ],
            ),
            const SizedBox(height: 24),

            // Splits Breakdown & Bar Chart
            if (_effectiveSession.splits.isNotEmpty) ...[
              const Text(
                'Kilometer Splits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Bar Chart for Splits
              Container(
                height: 180,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 8.0,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, _) => Text(
                            '${val.toInt()}m',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) => Text(
                            'Km ${val.toInt() + 1}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _effectiveSession.splits.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final split = entry.value;
                      final minutes = split.paceSecondsPerKm / 60.0;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: minutes.clamp(1.0, 8.0),
                            color: SankalpTheme.brandYellow,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Splits Table
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('KM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('PACE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('ELEVATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    ..._effectiveSession.splits.map((split) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text('${split.splitIndex}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('${split.formattedPace} /km')),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${split.elevationChangeMeters >= 0 ? '+' : ''}${split.elevationChangeMeters.toStringAsFixed(1)} m',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: split.elevationChangeMeters >= 0 ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Elevation Profile Chart
            const Text(
              'Elevation Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (val, _) => Text(
                          '${val.toInt()}m',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _effectiveSession.points.isNotEmpty
                          ? _effectiveSession.points.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.altitude);
                            }).toList()
                          : const [FlSpot(0, 0)],
                      isCurved: true,
                      color: SankalpTheme.brandYellow,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Settings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy & Protection',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Hide Start & Finish (200m buffer)', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Obscures home or work coordinates when exporting or sharing.', style: TextStyle(fontSize: 12)),
                    value: _hidePrivacyZones,
                    activeThumbColor: SankalpTheme.brandYellow,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _hidePrivacyZones = val),
                  ),
                  SwitchListTile(
                    title: const Text('Private Activity', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Keep workout strictly confidential on local device and cloud.', style: TextStyle(fontSize: 12)),
                    value: _isPrivate,
                    activeThumbColor: SankalpTheme.brandYellow,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _isPrivate = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Bottom Return Button
            ElevatedButton(
              onPressed: () => context.go('/app/today'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFFFC727),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Done • Return to Dashboard', maxLines: 1, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SankalpTheme.brandYellow.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF946A00), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
