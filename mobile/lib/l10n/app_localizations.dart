import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sankalp'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Disciplined habit transformation and digital detox platform'**
  String get appTagline;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get navChallenges;

  /// No description provided for @navTracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get navTracker;

  /// No description provided for @navDetox.
  ///
  /// In en, this message translates to:
  /// **'Focus & Detox'**
  String get navDetox;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @todayChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Discipline'**
  String get todayChecklistTitle;

  /// No description provided for @streakBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String streakBanner(int count);

  /// No description provided for @streakFreezesActive.
  ///
  /// In en, this message translates to:
  /// **'{count} Freezes active'**
  String streakFreezesActive(int count);

  /// No description provided for @dailyXpEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} XP gained today'**
  String dailyXpEarned(int count);

  /// No description provided for @challenge21Day.
  ///
  /// In en, this message translates to:
  /// **'21-Day Habit Builder'**
  String get challenge21Day;

  /// No description provided for @challenge90Day.
  ///
  /// In en, this message translates to:
  /// **'90-Day Transformation Overhaul'**
  String get challenge90Day;

  /// No description provided for @challengeSummerArc.
  ///
  /// In en, this message translates to:
  /// **'Summer Arc Regimen'**
  String get challengeSummerArc;

  /// No description provided for @challengeWinterArc.
  ///
  /// In en, this message translates to:
  /// **'Winter Arc Discipline'**
  String get challengeWinterArc;

  /// No description provided for @trackerLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get trackerLiveTitle;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout Session'**
  String get startWorkout;

  /// No description provided for @stopWorkout.
  ///
  /// In en, this message translates to:
  /// **'Hold to Stop'**
  String get stopWorkout;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @avgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg Pace'**
  String get avgPace;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String caloriesKcal(int calories);

  /// No description provided for @splitsHeader.
  ///
  /// In en, this message translates to:
  /// **'Kilometer Splits'**
  String get splitsHeader;

  /// No description provided for @detoxDeepWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Focus Timer'**
  String get detoxDeepWorkTitle;

  /// No description provided for @detoxScreenTimeBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily Screen Time Budget'**
  String get detoxScreenTimeBudget;

  /// No description provided for @detoxDistractionsBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} Distractions Blocked'**
  String detoxDistractionsBlocked(int count);

  /// No description provided for @detoxSilenceNotifications.
  ///
  /// In en, this message translates to:
  /// **'Silence Notifications (DND)'**
  String get detoxSilenceNotifications;

  /// No description provided for @detoxStartSession.
  ///
  /// In en, this message translates to:
  /// **'Begin Deep Work Session'**
  String get detoxStartSession;

  /// No description provided for @detoxEndEarly.
  ///
  /// In en, this message translates to:
  /// **'End Focus Session Early'**
  String get detoxEndEarly;

  /// No description provided for @detoxUsagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Usage Access Required for App Blocker'**
  String get detoxUsagePermissionRequired;

  /// No description provided for @gamificationBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline Badges'**
  String get gamificationBadgesTitle;

  /// No description provided for @gamificationLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Progression'**
  String get gamificationLevelsTitle;

  /// No description provided for @gamificationLeaguesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline Leagues'**
  String get gamificationLeaguesTitle;

  /// No description provided for @gamificationCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} • {title}'**
  String gamificationCurrentLevel(int level, String title);

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @quietHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours (Sleep Mode)'**
  String get quietHoursTitle;

  /// No description provided for @frequencyCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Frequency Cap'**
  String get frequencyCapTitle;

  /// No description provided for @themeDayMode.
  ///
  /// In en, this message translates to:
  /// **'Day Mode (Yellow & White)'**
  String get themeDayMode;

  /// No description provided for @themeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDarkMode;

  /// No description provided for @themeNightMode.
  ///
  /// In en, this message translates to:
  /// **'Night Mode (Pure AMOLED)'**
  String get themeNightMode;

  /// No description provided for @themeCustomMode.
  ///
  /// In en, this message translates to:
  /// **'Custom Accent Mode'**
  String get themeCustomMode;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get btnShare;

  /// No description provided for @btnExportGpx.
  ///
  /// In en, this message translates to:
  /// **'Export GPX'**
  String get btnExportGpx;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
