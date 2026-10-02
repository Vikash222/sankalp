import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arclife/core/storage/token_storage.dart';
import 'package:arclife/core/theme/theme_notifier.dart';
import 'package:arclife/main.dart';

void main() {
  testWidgets('SankalpApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
        child: const SankalpApp(),
      ),
    );

    // Initial frame
    await tester.pump();
    expect(find.byType(SankalpApp), findsOneWidget);

    // Advance past splash screen delay to resolve pending timer
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
