// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'संकल्प';

  @override
  String get appTagline => 'अनुशासित आदत परिवर्तन और डिजिटल डिटॉक्स मंच';

  @override
  String get navToday => 'आज';

  @override
  String get navChallenges => 'चुनौतियाँ';

  @override
  String get navTracker => 'ट्रैकर';

  @override
  String get navDetox => 'फोकस और डिटॉक्स';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get todayChecklistTitle => 'आज का अनुशासन';

  @override
  String streakBanner(int count) {
    return '$count दिन की निरंतरता';
  }

  @override
  String streakFreezesActive(int count) {
    return '$count स्ट्रीक फ़्रीज़ सक्रिय';
  }

  @override
  String dailyXpEarned(int count) {
    return 'आज $count XP अर्जित';
  }

  @override
  String get challenge21Day => '21-दिवसीय आदत निर्माता';

  @override
  String get challenge90Day => '90-दिवसीय संपूर्ण जीवन परिवर्तन';

  @override
  String get challengeSummerArc => 'समर आर्क अनुशासन';

  @override
  String get challengeWinterArc => 'विंटर आर्क कठोर तपस्या';

  @override
  String get trackerLiveTitle => 'लाइव ट्रैकिंग';

  @override
  String get startWorkout => 'व्यायाम सत्र शुरू करें';

  @override
  String get stopWorkout => 'रोकने हेतु दबाए रखें';

  @override
  String distanceKm(String distance) {
    return '$distance किमी';
  }

  @override
  String get avgPace => 'औसत गति';

  @override
  String get duration => 'अवधि';

  @override
  String caloriesKcal(int calories) {
    return '$calories किलोकैलोरी';
  }

  @override
  String get splitsHeader => 'किलोमीटर विभाजन';

  @override
  String get detoxDeepWorkTitle => 'डीप वर्क एकाग्रता टाइमर';

  @override
  String get detoxScreenTimeBudget => 'दैनिक स्क्रीन समय सीमा';

  @override
  String detoxDistractionsBlocked(int count) {
    return '$count भटकाव अवरुद्ध';
  }

  @override
  String get detoxSilenceNotifications => 'सूचनाएं मूक करें (DND)';

  @override
  String get detoxStartSession => 'डीप वर्क सत्र प्रारंभ करें';

  @override
  String get detoxEndEarly => 'सत्र समय से पहले समाप्त करें';

  @override
  String get detoxUsagePermissionRequired =>
      'ऐप ब्लॉकर हेतु उपयोग अनुमति आवश्यक';

  @override
  String get gamificationBadgesTitle => 'अनुशासन पदक';

  @override
  String get gamificationLevelsTitle => 'स्तर प्रगति';

  @override
  String get gamificationLeaguesTitle => 'अनुशासन लीग';

  @override
  String gamificationCurrentLevel(int level, String title) {
    return 'स्तर $level • $title';
  }

  @override
  String get notificationSettingsTitle => 'सूचना सेटिंग्स';

  @override
  String get quietHoursTitle => 'शांति का समय (विश्राम मोड)';

  @override
  String get frequencyCapTitle => 'दैनिक सूचना सीमा';

  @override
  String get themeDayMode => 'डे मोड (पीला और श्वेत)';

  @override
  String get themeDarkMode => 'डार्क मोड';

  @override
  String get themeNightMode => 'नाइट मोड (पूर्ण AMOLED)';

  @override
  String get themeCustomMode => 'कस्टम रंग मोड';

  @override
  String get btnDone => 'संपन्न';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnSave => 'सहेजें';

  @override
  String get btnShare => 'साझा करें';

  @override
  String get btnExportGpx => 'GPX निर्यात करें';
}
