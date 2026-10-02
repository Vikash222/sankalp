import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TokenStorage {
  static const String _keyToken = 'sankalp_auth_token';
  static const String _keyDeviceUuid = 'sankalp_device_uuid';
  static const String _keyIsGuest = 'sankalp_is_guest';
  static const String _keyThemeMode = 'sankalp_theme_mode';
  static const String _keyLanguage = 'sankalp_language';
  static const String _keyHasCompletedQuiz = 'sankalp_has_completed_quiz';

  static const String _keyUserName = 'sankalp_user_name';
  static const String _keyUserEmail = 'sankalp_user_email';
  static const String _keyUserXp = 'sankalp_user_xp';
  static const String _keyActiveChallenge = 'sankalp_active_challenge';
  static const String _keyUnlockedBadges = 'sankalp_unlocked_badges';

  final SharedPreferences _prefs;
  SharedPreferences get prefs => _prefs;

  TokenStorage(this._prefs);

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage(prefs);
  }

  // Auth Token
  String? getToken() => _prefs.getString(_keyToken);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserEmail);
  }

  // Device UUID
  String getOrCreateDeviceUuid() {
    String? uuid = _prefs.getString(_keyDeviceUuid);
    if (uuid == null || uuid.isEmpty) {
      uuid = const Uuid().v4();
      _prefs.setString(_keyDeviceUuid, uuid);
    }
    return uuid;
  }

  // Guest status
  bool isGuest() => _prefs.getBool(_keyIsGuest) ?? false;

  Future<void> setGuest(bool isGuest) async {
    await _prefs.setBool(_keyIsGuest, isGuest);
  }

  // User Profile
  String getUserName() => _prefs.getString(_keyUserName) ?? 'Sankalp Practitioner';
  Future<void> setUserName(String name) async => _prefs.setString(_keyUserName, name);

  String? getUserEmail() => _prefs.getString(_keyUserEmail);
  Future<void> setUserEmail(String? email) async {
    if (email == null) {
      await _prefs.remove(_keyUserEmail);
    } else {
      await _prefs.setString(_keyUserEmail, email);
    }
  }

  int getUserXp() => _prefs.getInt(_keyUserXp) ?? 0;
  Future<void> setUserXp(int xp) async => _prefs.setInt(_keyUserXp, xp);

  String getActiveChallenge() => _prefs.getString(_keyActiveChallenge) ?? '21-day';
  Future<void> setActiveChallenge(String slug) async => _prefs.setString(_keyActiveChallenge, slug);

  List<String> getUnlockedBadges() =>
      _prefs.getStringList(_keyUnlockedBadges) ?? const [];

  Future<void> setUnlockedBadges(List<String> badges) async =>
      _prefs.setStringList(_keyUnlockedBadges, badges);

  Future<void> unlockBadge(String slug) async {
    final list = List<String>.from(getUnlockedBadges());
    if (!list.contains(slug)) {
      list.add(slug);
      await setUnlockedBadges(list);
    }
  }

  // Theme Mode ('day', 'dark', 'night', 'custom')
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'day';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // Language ('en', 'hi')
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'en';

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }

  // Quiz status
  bool hasCompletedQuiz() => _prefs.getBool(_keyHasCompletedQuiz) ?? false;

  Future<void> setCompletedQuiz(bool completed) async {
    await _prefs.setBool(_keyHasCompletedQuiz, completed);
  }
}
