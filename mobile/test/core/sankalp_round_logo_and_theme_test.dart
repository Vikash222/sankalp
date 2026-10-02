import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arclife/core/widgets/sankalp_round_logo.dart';
import 'package:arclife/core/theme/sankalp_theme.dart';

void main() {
  group('SankalpRoundLogo & SankalpAppBar Widget Tests', () {
    testWidgets('Renders multiple SankalpRoundLogo widgets without Hero tag conflicts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SankalpRoundLogo(size: 32),
                SankalpRoundLogo(size: 40),
                SankalpRoundLogo(size: 60),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SankalpRoundLogo), findsNWidgets(3));
    });

    testWidgets('SankalpAppBar displays title and circular logo in leading area',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: SankalpAppBar(
              title: 'Discipline Roadmap',
              showBackButton: true,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );

      expect(find.text('Discipline Roadmap'), findsOneWidget);
      expect(find.byType(SankalpRoundLogo), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  group('SankalpTheme Mode Verification', () {
    test('Day Theme provides yellow primary and light scaffold', () {
      final theme = SankalpTheme.dayTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFFFFC727));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFCFBF7));
    });

    test('Dark Theme provides dark brightness and slate background', () {
      final theme = SankalpTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFFFFC727));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF12141A));
    });

    test('Night Theme provides pure AMOLED black background', () {
      final theme = SankalpTheme.nightTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
    });

    test('Custom Theme generates accessible onPrimary color', () {
      final customLight = SankalpTheme.customTheme(
        primaryColor: const Color(0xFFFFC727),
        isDark: false,
      );
      expect(customLight.colorScheme.onPrimary, const Color(0xFF1A1A1A));

      final customDark = SankalpTheme.customTheme(
        primaryColor: const Color(0xFF1A237E),
        isDark: true,
      );
      expect(customDark.colorScheme.onPrimary, const Color(0xFFFFFFFF));
    });
  });
}
