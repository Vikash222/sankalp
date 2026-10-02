import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../data/datasources/workout_storage.dart';
import '../../domain/entities/activity_type.dart';
import '../../domain/entities/tracking_session.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  ActivityType? _selectedFilter; // null means 'All'
  List<TrackingSession> _allWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final storage = ref.read(workoutStorageProvider);
      final list = await storage.getWorkouts();
      if (!mounted) return;
      setState(() {
        _allWorkouts = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<double> _computeWeeklyDailyDistances() {
    final now = DateTime.now();
    // Start of current week (Monday)
    final monday = now.subtract(Duration(days: (now.weekday - 1) % 7));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);

    final daily = List<double>.filled(7, 0.0);
    for (final w in _allWorkouts) {
      if (w.startedAt.isAfter(startOfMonday)) {
        final diffDays = w.startedAt.difference(startOfMonday).inDays;
        if (diffDays >= 0 && diffDays < 7) {
          daily[diffDays] += w.distanceMeters / 1000.0;
        }
      }
    }
    return daily;
  }

  double _computeTotalWeeklyMileage(List<double> daily) {
    return daily.fold(0.0, (acc, d) => acc + d);
  }

  String _computeFastestPace() {
    if (_allWorkouts.isEmpty) return '--:--';
    int minPace = 999999;
    for (final w in _allWorkouts) {
      if (w.avgPaceSecondsPerKm > 0 && w.avgPaceSecondsPerKm < minPace) {
        minPace = w.avgPaceSecondsPerKm;
      }
    }
    if (minPace == 999999) return '--:--';
    final m = minPace ~/ 60;
    final s = minPace % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _computeLongestRun() {
    if (_allWorkouts.isEmpty) return '0.0';
    double maxDistM = 0.0;
    for (final w in _allWorkouts) {
      if (w.distanceMeters > maxDistM) {
        maxDistM = w.distanceMeters;
      }
    }
    return (maxDistM / 1000.0).toStringAsFixed(1);
  }

  String _computeTopSpeed() {
    if (_allWorkouts.isEmpty) return '0.0';
    double maxSpeed = 0.0;
    for (final w in _allWorkouts) {
      if (w.maxSpeedMps > maxSpeed) {
        maxSpeed = w.maxSpeedMps;
      }
    }
    return (maxSpeed * 3.6).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final filteredWorkouts = _selectedFilter == null
        ? _allWorkouts
        : _allWorkouts.where((w) => w.type == _selectedFilter).toList();

    final dailyDistances = _computeWeeklyDailyDistances();
    final weeklyTotalKm = _computeTotalWeeklyMileage(dailyDistances);
    final maxBarY = (dailyDistances.fold(0.0, (m, d) => d > m ? d : m) * 1.25)
        .clamp(5.0, 50.0);

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Workout History',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWorkouts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('All Activities'),
                              selected: _selectedFilter == null,
                              onSelected: (_) {
                                setState(() => _selectedFilter = null);
                              },
                              selectedColor: SankalpTheme.brandYellow,
                              backgroundColor: Colors.grey.withValues(alpha: 0.1),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedFilter == null
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ...ActivityType.values.map((type) {
                            final isSelected = _selectedFilter == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.displayName),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedFilter =
                                      selected ? type : null);
                                },
                                selectedColor: SankalpTheme.brandYellow,
                                backgroundColor:
                                    Colors.grey.withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal Records Showcase
                    const Text(
                      'Personal Records',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildPrCard('BEST PACE', _computeFastestPace(),
                              'min/km', Icons.military_tech_rounded),
                          _buildPrCard('LONGEST WORKOUT', _computeLongestRun(),
                              'km', Icons.flag_circle_rounded),
                          _buildPrCard('TOP SPEED', _computeTopSpeed(), 'km/h',
                              Icons.speed_rounded),
                          _buildPrCard('TOTAL SESSIONS',
                              _allWorkouts.length.toString(), 'logged',
                              Icons.bolt_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Weekly Mileage Progression
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'THIS WEEK\'S MILEAGE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: SankalpTheme.brandYellow
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${weeklyTotalKm.toStringAsFixed(1)} km Total',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF946A00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 150,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxBarY,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, _) {
                                        const days = [
                                          'M',
                                          'T',
                                          'W',
                                          'T',
                                          'F',
                                          'S',
                                          'S'
                                        ];
                                        final idx = val.toInt();
                                        if (idx < 0 || idx >= days.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Text(
                                          days[idx],
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(7, (i) {
                                  return _buildBarGroup(i, dailyDistances[i]);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Workout History List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activities (${filteredWorkouts.length})',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredWorkouts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.directions_run_rounded,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              const Text(
                                'No Activities Recorded Yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Start an outdoor running or walking session to see your route and telemetry here.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/app/tracker'),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start First Workout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SankalpTheme.brandYellow,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filteredWorkouts.map((workout) {
                        final type = workout.type;
                        final IconData icon = switch (type) {
                          ActivityType.run => Icons.directions_run_rounded,
                          ActivityType.walk => Icons.directions_walk_rounded,
                          ActivityType.cycle => Icons.directions_bike_rounded,
                          ActivityType.hike => Icons.terrain_rounded,
                        };
                        final dateStr = DateFormat('MMM d, h:mm a')
                            .format(workout.startedAt);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push(
                                '/tracker/summary',
                                extra: workout,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: SankalpTheme.brandYellow
                                            .withValues(alpha: 0.18),
                                      ),
                                      child: Icon(icon,
                                          color: const Color(0xFF946A00),
                                          size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            type.displayName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$dateStr • ${workout.formattedMovingTime}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Pace: ${workout.formattedAvgPace} • ${workout.calories} kcal',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${workout.formattedDistanceKm} km',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.chevron_right_rounded,
                                            color: Colors.grey, size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrCard(
      String title, String value, String unit, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.grey),
              ),
              Icon(icon, size: 16, color: const Color(0xFF946A00)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 0
              ? SankalpTheme.brandYellow
              : Colors.grey.withValues(alpha: 0.15),
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
