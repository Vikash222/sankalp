import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_notifier.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';

enum SyncItemType {
  habitCheckIn,
  activityWorkout,
  focusSession,
}

enum SyncStateStatus {
  idle,
  syncing,
  synced,
  error,
}

class SyncQueueItem {
  final String id;
  final SyncItemType type;
  final String endpoint;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'endpoint': endpoint,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'retry_count': retryCount,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: SyncItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncItemType.habitCheckIn,
      ),
      endpoint: json['endpoint'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  SyncQueueItem copyWith({int? retryCount}) {
    return SyncQueueItem(
      id: id,
      type: type,
      endpoint: endpoint,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class OfflineSyncEngine {
  static const String _storageKey = 'sankalp_offline_sync_queue';
  final SharedPreferences prefs;
  final DioClient dioClient;

  final _syncStatusController = StreamController<SyncStateStatus>.broadcast();
  Stream<SyncStateStatus> get statusStream => _syncStatusController.stream;

  SyncStateStatus _currentStatus = SyncStateStatus.idle;
  SyncStateStatus get currentStatus => _currentStatus;

  OfflineSyncEngine({
    required this.prefs,
    required this.dioClient,
  });

  /// Retrieve all pending mutations queued in local storage.
  List<SyncQueueItem> getPendingQueue() {
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return SyncQueueItem.fromJson(map);
    }).toList();
  }

  /// Total count of items awaiting synchronization.
  int get pendingCount => getPendingQueue().length;

  /// Enqueue an idempotent habit check-in mutation.
  Future<void> enqueueHabitCheckIn({
    required int habitId,
    required String date,
    required bool completed,
  }) async {
    final item = SyncQueueItem(
      id: const Uuid().v4(),
      type: SyncItemType.habitCheckIn,
      endpoint: '${ApiEndpoints.habits}/$habitId/logs',
      payload: {
        'date': date,
        'completed': completed,
        'client_uuid': const Uuid().v4(),
      },
      createdAt: DateTime.now(),
    );
    await _enqueue(item);
  }

  /// Enqueue a completed workout session with unique client UUID.
  Future<void> enqueueWorkout(Map<String, dynamic> workoutPayload) async {
    final item = SyncQueueItem(
      id: workoutPayload['client_uuid'] as String? ?? const Uuid().v4(),
      type: SyncItemType.activityWorkout,
      endpoint: ApiEndpoints.activities,
      payload: workoutPayload,
      createdAt: DateTime.now(),
    );
    await _enqueue(item);
  }

  /// Enqueue a completed digital detox deep work session.
  Future<void> enqueueFocusSession(Map<String, dynamic> sessionPayload) async {
    final item = SyncQueueItem(
      id: const Uuid().v4(),
      type: SyncItemType.focusSession,
      endpoint: ApiEndpoints.focusSessions,
      payload: sessionPayload,
      createdAt: DateTime.now(),
    );
    await _enqueue(item);
  }

  Future<void> _enqueue(SyncQueueItem item) async {
    final queue = getPendingQueue();
    // Prevent duplicate enqueues for identical IDs
    if (!queue.any((q) => q.id == item.id)) {
      queue.add(item);
      await _saveQueue(queue);
    }
  }

  Future<void> _saveQueue(List<SyncQueueItem> queue) async {
    final encoded = queue.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  /// Attempt to synchronize all pending mutations to the Laravel backend.
  ///
  /// Returns the number of successfully synchronized mutations.
  Future<int> syncPendingMutations() async {
    final queue = getPendingQueue();
    if (queue.isEmpty) {
      _setStatus(SyncStateStatus.synced);
      return 0;
    }

    _setStatus(SyncStateStatus.syncing);
    int successCount = 0;
    final remainingQueue = <SyncQueueItem>[];

    for (final item in queue) {
      try {
        final response = await dioClient.post<Map<String, dynamic>>(
          item.endpoint,
          data: item.payload,
        );

        if (response.success) {
          successCount++;
        } else {
          // Server returned an error, increment retry count
          remainingQueue.add(item.copyWith(retryCount: item.retryCount + 1));
        }
      } catch (e) {
        debugPrint('Sync failed for item ${item.id}: $e');
        // Network timeout / offline, keep in queue
        remainingQueue.add(item.copyWith(retryCount: item.retryCount + 1));
      }
    }

    await _saveQueue(remainingQueue);

    if (remainingQueue.isEmpty) {
      _setStatus(SyncStateStatus.synced);
    } else {
      _setStatus(SyncStateStatus.error);
    }

    return successCount;
  }

  /// Clear the local sync queue (e.g. on user logout).
  Future<void> clearQueue() async {
    await prefs.remove(_storageKey);
    _setStatus(SyncStateStatus.idle);
  }

  void _setStatus(SyncStateStatus status) {
    _currentStatus = status;
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }

  void dispose() {
    _syncStatusController.close();
  }
}

final offlineSyncEngineProvider = Provider<OfflineSyncEngine>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = ref.watch(dioClientProvider);
  return OfflineSyncEngine(prefs: storage.prefs, dioClient: dio);
});
