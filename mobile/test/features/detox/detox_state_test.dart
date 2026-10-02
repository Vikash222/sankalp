import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/features/detox/presentation/providers/detox_notifier.dart';

void main() {
  group('DetoxState Unit Tests', () {
    test('Calculates progress ratio accurately during countdown', () {
      const state = DetoxState(
        selectedDurationMinutes: 25,
        secondsRemaining: 15 * 60, // 10 minutes elapsed
      );

      // (25 * 60 - 15 * 60) / (25 * 60) = 10 / 25 = 0.40
      expect(state.progressRatio, closeTo(0.40, 0.001));
    });

    test('Formats remaining time as MM:SS string', () {
      const state = DetoxState(
        secondsRemaining: 125, // 2 minutes and 5 seconds
      );

      expect(state.formattedTimeRemaining, equals('02:05'));
    });

    test('Toggles app blocking state via copyWith', () {
      const app = BlockedAppItem(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        isBlocked: true,
      );

      final unblocked = app.copyWith(isBlocked: false);
      expect(unblocked.isBlocked, isFalse);
      expect(unblocked.packageName, equals('com.instagram.android'));
    });
  });
}
