import 'package:arclife/core/storage/token_storage.dart';
import 'package:arclife/core/theme/sankalp_theme.dart';
import 'package:arclife/core/theme/theme_notifier.dart';
import 'package:arclife/features/auth/presentation/screens/login_screen.dart';
import 'package:arclife/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('Renders all registration fields and circular logo', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Sankalp Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Register Account'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('Validates required fields when submitting empty form', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Register Account without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter a password.'), findsOneWidget);
    });

    testWidgets('Validates email formatting and password match', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Sankalp Practitioner');
      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email Address'), 'notanemail');
      // Enter short password
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      // Enter non-matching confirm password
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), '456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters long.'), findsOneWidget);
      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all login fields and navigation options', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Do not have an account? '), findsOneWidget);
      expect(find.text('Register Now'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('Validates required fields when submitting empty login', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = TokenStorage(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            theme: SankalpTheme.dayTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });
  });
}
