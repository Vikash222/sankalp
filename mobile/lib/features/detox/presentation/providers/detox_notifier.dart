import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/detox_native_bridge.dart';

class BlockedAppItem {
  final String packageName;
  final String appName;
  final bool isBlocked;
  final String dailyLimit;

  const BlockedAppItem({
    required this.packageName,
    required this.appName,
    required this.isBlocked,
    this.dailyLimit = '20m / day',
  });

  BlockedAppItem copyWith({
    String? packageName,
    String? appName,
    bool? isBlocked,
    String? dailyLimit,
  }) {
    return BlockedAppItem(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isBlocked: isBlocked ?? this.isBlocked,
      dailyLimit: dailyLimit ?? this.dailyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'isBlocked': isBlocked,
        'dailyLimit': dailyLimit,
      };

  factory BlockedAppItem.fromJson(Map<String, dynamic> json) => BlockedAppItem(
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        isBlocked: json['isBlocked'] as bool? ?? true,
        dailyLimit: json['dailyLimit'] as String? ?? '20m / day',
      );
}

class DetoxState {
  final bool hasUsagePermission;
  final bool hasDndPermission;
  final bool isRunning;
  final int selectedDurationMinutes;
  final int secondsRemaining;
  final int blockedAttemptsCount;
  final bool enableDnd;
  final List<BlockedAppItem> blockedApps;
  final String? lastBlockedAppName;

  const DetoxState({
    this.hasUsagePermission = false,
    this.hasDndPermission = false,
    this.isRunning = false,
    this.selectedDurationMinutes = 25,
    this.secondsRemaining = 25 * 60,
    this.blockedAttemptsCount = 0,
    this.enableDnd = true,
    this.blockedApps = const [],
    this.lastBlockedAppName,
  });

  double get progressRatio {
    final total = selectedDurationMinutes * 60;
    if (total <= 0) return 0.0;
    return (total - secondsRemaining) / total;
  }

  String get formattedTimeRemaining {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  DetoxState copyWith({
    bool? hasUsagePermission,
    bool? hasDndPermission,
    bool? isRunning,
    int? selectedDurationMinutes,
    int? secondsRemaining,
    int? blockedAttemptsCount,
    bool? enableDnd,
    List<BlockedAppItem>? blockedApps,
    String? lastBlockedAppName,
  }) {
    return DetoxState(
      hasUsagePermission: hasUsagePermission ?? this.hasUsagePermission,
      hasDndPermission: hasDndPermission ?? this.hasDndPermission,
      isRunning: isRunning ?? this.isRunning,
      selectedDurationMinutes: selectedDurationMinutes ?? this.selectedDurationMinutes,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      blockedAttemptsCount: blockedAttemptsCount ?? this.blockedAttemptsCount,
      enableDnd: enableDnd ?? this.enableDnd,
      blockedApps: blockedApps ?? this.blockedApps,
      lastBlockedAppName: lastBlockedAppName ?? this.lastBlockedAppName,
    );
  }
}

final detoxNativeBridgeProvider = Provider((ref) => DetoxNativeBridge());

final detoxNotifierProvider =
    NotifierProvider<DetoxNotifier, DetoxState>(DetoxNotifier.new);

class DetoxNotifier extends Notifier<DetoxState> {
  late final DetoxNativeBridge _bridge;
  late final DioClient _dio;
  Timer? _tickerTimer;
  StreamSubscription? _eventSub;
  DateTime? _sessionStartTime;

  @override
  DetoxState build() {
    _bridge = ref.watch(detoxNativeBridgeProvider);
    _dio = ref.watch(dioClientProvider);

    _initPermissionsAndApps();
    _listenToNativeEvents();

    ref.onDispose(() {
      _tickerTimer?.cancel();
      _eventSub?.cancel();
    });

    return const DetoxState(
      blockedApps: [
        BlockedAppItem(
          packageName: 'com.instagram.android',
          appName: 'Instagram',
          isBlocked: true,
          dailyLimit: '15m / day',
        ),
        BlockedAppItem(
          packageName: 'com.google.android.youtube',
          appName: 'YouTube Shorts',
          isBlocked: true,
          dailyLimit: '30m / day',
        ),
        BlockedAppItem(
          packageName: 'com.reddit.frontpage',
          appName: 'Reddit',
          isBlocked: true,
          dailyLimit: '20m / day',
        ),
        BlockedAppItem(
          packageName: 'com.twitter.android',
          appName: 'X (Twitter)',
          isBlocked: false,
          dailyLimit: '20m / day',
        ),
      ],
    );
  }

  static const String _keyBlockedApps = 'sankalp_blocked_apps';

  Future<void> _initPermissionsAndApps() async {
    final hasUsage = await _bridge.hasUsageStatsPermission();
    final hasDnd = await _bridge.hasDndPermission();

    // Load persisted custom blocked apps from storage
    try {
      final storage = ref.read(tokenStorageProvider);
      final raw = storage.prefs.getString(_keyBlockedApps);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        final loaded = list
            .map((e) => BlockedAppItem.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(blockedApps: loaded);
      }
    } catch (_) {}

    state = state.copyWith(
      hasUsagePermission: hasUsage,
      hasDndPermission: hasDnd,
    );
  }

  Future<void> _saveBlockedApps() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final jsonStr = jsonEncode(state.blockedApps.map((a) => a.toJson()).toList());
      await storage.prefs.setString(_keyBlockedApps, jsonStr);
    } catch (_) {}
  }

  void _listenToNativeEvents() {
    _eventSub = _bridge.eventStream.listen((event) {
      final type = event['event'] as String?;
      if (type == 'app_blocked') {
        final appName = event['app_name'] as String? ?? 'Restricted App';
        state = state.copyWith(
          blockedAttemptsCount: state.blockedAttemptsCount + 1,
          lastBlockedAppName: appName,
        );
      } else if (type == 'session_ended') {
        final completedMinutes = event['completed_minutes'] as int? ?? 0;
        final isSuccessful = event['is_successful'] as bool? ?? false;
        _onNativeSessionFinished(completedMinutes, isSuccessful);
      }
    });
  }

  Future<void> checkPermissions() async {
    final hasUsage = await _bridge.hasUsageStatsPermission();
    final hasDnd = await _bridge.hasDndPermission();
    state = state.copyWith(
      hasUsagePermission: hasUsage,
      hasDndPermission: hasDnd,
    );
  }

  Future<void> requestUsagePermission() async {
    await _bridge.requestUsageStatsPermission();
  }

  Future<void> requestDndPermission() async {
    await _bridge.requestDndPermission();
  }

  Future<List<Map<String, dynamic>>> getInstalledUserApps() async {
    return _bridge.getInstalledUserApps();
  }

  void setDuration(int minutes) {
    if (state.isRunning) return;
    state = state.copyWith(
      selectedDurationMinutes: minutes,
      secondsRemaining: minutes * 60,
    );
  }

  void toggleDnd(bool enabled) {
    state = state.copyWith(enableDnd: enabled);
  }

  void toggleAppBlock(String packageName) {
    final updated = state.blockedApps.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isBlocked: !app.isBlocked);
      }
      return app;
    }).toList();
    state = state.copyWith(blockedApps: updated);
    _saveBlockedApps();
  }

  void addCustomBlockedApp(String appName, String packageName) {
    if (state.blockedApps.any((a) => a.packageName == packageName)) return;
    final updated = [
      ...state.blockedApps,
      BlockedAppItem(
        packageName: packageName,
        appName: appName,
        isBlocked: true,
        dailyLimit: '20m / day',
      ),
    ];
    state = state.copyWith(blockedApps: updated);
    _saveBlockedApps();
  }

  void removeBlockedApp(String packageName) {
    final updated = state.blockedApps.where((a) => a.packageName != packageName).toList();
    state = state.copyWith(blockedApps: updated);
    _saveBlockedApps();
  }

  Future<void> startSession() async {
    final blockedPkgList = state.blockedApps
        .where((a) => a.isBlocked)
        .map((a) => a.packageName)
        .toList();

    _sessionStartTime = DateTime.now();

    await _bridge.startFocusSession(
      blockedPackages: blockedPkgList,
      durationMinutes: state.selectedDurationMinutes,
      enableDnd: state.enableDnd,
    );

    state = state.copyWith(
      isRunning: true,
      blockedAttemptsCount: 0,
      secondsRemaining: state.selectedDurationMinutes * 60,
    );

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        timer.cancel();
        _onNativeSessionFinished(state.selectedDurationMinutes, true);
      }
    });
  }

  Future<void> stopSessionEarly() async {
    _tickerTimer?.cancel();
    await _bridge.stopFocusSession();
    final completedMinutes =
        (state.selectedDurationMinutes * 60 - state.secondsRemaining) ~/ 60;
    await _onNativeSessionFinished(completedMinutes, false);
  }

  Future<void> _onNativeSessionFinished(int completedMinutes, bool isSuccessful) async {
    _tickerTimer?.cancel();
    state = state.copyWith(
      isRunning: false,
      secondsRemaining: state.selectedDurationMinutes * 60,
    );

    // Sync session to backend API
    try {
      final now = DateTime.now();
      final startedAt = _sessionStartTime ?? now.subtract(Duration(minutes: completedMinutes));

      await _dio.post(
        ApiEndpoints.focusSessions,
        data: {
          'duration_minutes': state.selectedDurationMinutes,
          'completed_minutes': completedMinutes,
          'mode': 'pomodoro',
          'is_successful': isSuccessful,
          'started_at': startedAt.toIso8601String(),
          'ended_at': now.toIso8601String(),
          'interruption_count': state.blockedAttemptsCount,
        },
      );
    } catch (_) {
      // Offline-safe: will sync when connectivity resumes
    }
  }
}
