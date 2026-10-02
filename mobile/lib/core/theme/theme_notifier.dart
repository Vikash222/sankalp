import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'sankalp_theme.dart';

class ThemeState {
  final SankalpThemeMode mode;
  final Color customPrimaryColor;

  const ThemeState({
    required this.mode,
    this.customPrimaryColor = const Color(0xFFFFC727),
  });

  ThemeData get themeData {
    return switch (mode) {
      SankalpThemeMode.day => SankalpTheme.dayTheme,
      SankalpThemeMode.dark => SankalpTheme.darkTheme,
      SankalpThemeMode.night => SankalpTheme.nightTheme,
      SankalpThemeMode.custom => SankalpTheme.customTheme(
          primaryColor: customPrimaryColor,
          isDark: false,
        ),
    };
  }

  ThemeState copyWith({
    SankalpThemeMode? mode,
    Color? customPrimaryColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  late final TokenStorage _storage;

  @override
  ThemeState build() {
    _storage = ref.watch(tokenStorageProvider);
    final savedMode = _storage.getThemeMode();
    final mode = switch (savedMode) {
      'dark' => SankalpThemeMode.dark,
      'night' => SankalpThemeMode.night,
      'custom' => SankalpThemeMode.custom,
      _ => SankalpThemeMode.day,
    };
    return ThemeState(mode: mode);
  }

  Future<void> setThemeMode(SankalpThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _storage.setThemeMode(mode.name);
  }

  Future<void> setCustomPrimaryColor(Color color) async {
    state = state.copyWith(
      mode: SankalpThemeMode.custom,
      customPrimaryColor: color,
    );
    await _storage.setThemeMode('custom');
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  throw UnimplementedError('tokenStorageProvider must be overridden in ProviderScope');
});

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
