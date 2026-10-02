// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sankalp';

  @override
  String get appTagline =>
      'Disciplined habit transformation and digital detox platform';

  @override
  String get navToday => 'Today';

  @override
  String get navChallenges => 'Challenges';

  @override
  String get navTracker => 'Tracker';

  @override
  String get navDetox => 'Focus & Detox';

  @override
  String get navProfile => 'Profile';

  @override
  String get todayChecklistTitle => 'Today\'s Discipline';

  @override
  String streakBanner(int count) {
    return '$count Day Streak';
  }

  @override
  String streakFreezesActive(int count) {
    return '$count Freezes active';
  }

  @override
  String dailyXpEarned(int count) {
    return '$count XP gained today';
  }

  @override
  String get challenge21Day => '21-Day Habit Builder';

  @override
  String get challenge90Day => '90-Day Transformation Overhaul';

  @override
  String get challengeSummerArc => 'Summer Arc Regimen';

  @override
  String get challengeWinterArc => 'Winter Arc Discipline';

  @override
  String get trackerLiveTitle => 'Live Tracking';

  @override
  String get startWorkout => 'Start Workout Session';

  @override
  String get stopWorkout => 'Hold to Stop';

  @override
  String distanceKm(String distance) {
    return '$distance km';
  }

  @override
  String get avgPace => 'Avg Pace';

  @override
  String get duration => 'Duration';

  @override
  String caloriesKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String get splitsHeader => 'Kilometer Splits';

  @override
  String get detoxDeepWorkTitle => 'Deep Work Focus Timer';

  @override
  String get detoxScreenTimeBudget => 'Daily Screen Time Budget';

  @override
  String detoxDistractionsBlocked(int count) {
    return '$count Distractions Blocked';
  }

  @override
  String get detoxSilenceNotifications => 'Silence Notifications (DND)';

  @override
  String get detoxStartSession => 'Begin Deep Work Session';

  @override
  String get detoxEndEarly => 'End Focus Session Early';

  @override
  String get detoxUsagePermissionRequired =>
      'Usage Access Required for App Blocker';

  @override
  String get gamificationBadgesTitle => 'Discipline Badges';

  @override
  String get gamificationLevelsTitle => 'Level Progression';

  @override
  String get gamificationLeaguesTitle => 'Discipline Leagues';

  @override
  String gamificationCurrentLevel(int level, String title) {
    return 'Level $level • $title';
  }

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get quietHoursTitle => 'Quiet Hours (Sleep Mode)';

  @override
  String get frequencyCapTitle => 'Daily Frequency Cap';

  @override
  String get themeDayMode => 'Day Mode (Yellow & White)';

  @override
  String get themeDarkMode => 'Dark Mode';

  @override
  String get themeNightMode => 'Night Mode (Pure AMOLED)';

  @override
  String get themeCustomMode => 'Custom Accent Mode';

  @override
  String get btnDone => 'Done';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnShare => 'Share';

  @override
  String get btnExportGpx => 'Export GPX';
}
