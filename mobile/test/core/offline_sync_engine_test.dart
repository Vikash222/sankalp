import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arclife/core/network/dio_client.dart';
import 'package:arclife/core/storage/token_storage.dart';
import 'package:arclife/core/sync/offline_sync_engine.dart';

void main() {
  group('OfflineSyncEngine Unit Tests', () {
    late SharedPreferences prefs;
    late OfflineSyncEngine engine;
    late DioClient dioClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      final tokenStorage = TokenStorage(prefs);
      dioClient = DioClient(tokenStorage: tokenStorage);
      engine = OfflineSyncEngine(prefs: prefs, dioClient: dioClient);
    });

    test('Enqueues habit check-in and persists to local storage', () async {
      expect(engine.pendingCount, equals(0));

      await engine.enqueueHabitCheckIn(
        habitId: 101,
        date: '2026-10-02',
        completed: true,
      );

      expect(engine.pendingCount, equals(1));
      final queue = engine.getPendingQueue();
      expect(queue.first.type, equals(SyncItemType.habitCheckIn));
      expect(queue.first.payload['completed'], equals(true));
      expect(queue.first.endpoint.contains('/habits/101/logs'), isTrue);
    });

    test('Enqueues workout session and preserves client_uuid idempotency', () async {
      final workoutPayload = {
        'client_uuid': 'unique-run-12345',
        'type': 'run',
        'distance_m': 5020.0,
        'moving_time_s': 1580,
      };

      await engine.enqueueWorkout(workoutPayload);

      expect(engine.pendingCount, equals(1));
      final queue = engine.getPendingQueue();
      expect(queue.first.type, equals(SyncItemType.activityWorkout));
      expect(queue.first.id, equals('unique-run-12345'));
    });

    test('Clears pending queue completely', () async {
      await engine.enqueueHabitCheckIn(
        habitId: 101,
        date: '2026-10-02',
        completed: true,
      );
      await engine.enqueueFocusSession({
        'duration_minutes': 25,
        'mode': 'pomodoro',
      });

      expect(engine.pendingCount, equals(2));

      await engine.clearQueue();
      expect(engine.pendingCount, equals(0));
    });
  });
}
