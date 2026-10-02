import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/theme_notifier.dart';

class GamificationState {
  final int totalXp;
  final int level;
  final String activeChallengeSlug;
  final List<String> unlockedBadgeSlugs;

  const GamificationState({
    required this.totalXp,
    required this.level,
    required this.activeChallengeSlug,
    required this.unlockedBadgeSlugs,
  });

  bool isBadgeUnlocked(String slug) => unlockedBadgeSlugs.contains(slug);

  GamificationState copyWith({
    int? totalXp,
    int? level,
    String? activeChallengeSlug,
    List<String>? unlockedBadgeSlugs,
  }) {
    return GamificationState(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      activeChallengeSlug: activeChallengeSlug ?? this.activeChallengeSlug,
      unlockedBadgeSlugs: unlockedBadgeSlugs ?? this.unlockedBadgeSlugs,
    );
  }
}

class GamificationNotifier extends Notifier<GamificationState> {
  late final TokenStorage _storage;

  @override
  GamificationState build() {
    _storage = ref.watch(tokenStorageProvider);
    final xp = _storage.getUserXp();
    final challenge = _storage.getActiveChallenge();
    final badges = _storage.getUnlockedBadges();
    final level = _calculateLevel(xp);

    return GamificationState(
      totalXp: xp,
      level: level,
      activeChallengeSlug: challenge,
      unlockedBadgeSlugs: badges,
    );
  }

  static int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 450) return 3;
    if (xp < 700) return 4;
    if (xp < 1000) return 5;
    if (xp < 1400) return 6;
    if (xp < 1800) return 7;
    if (xp < 2300) return 8;
    if (xp < 3000) return 9;
    if (xp < 4000) return 10;
    return ((xp / 350).floor() + 1).clamp(1, 50);
  }

  Future<void> addXp(int points) async {
    final newXp = state.totalXp + points;
    final newLevel = _calculateLevel(newXp);
    await _storage.setUserXp(newXp);

    // Auto-check for milestone badges
    final updatedBadges = List<String>.from(state.unlockedBadgeSlugs);
    if (newXp >= 25 && !updatedBadges.contains('first-step')) {
      updatedBadges.add('first-step');
    }
    if (newLevel >= 5 && !updatedBadges.contains('3-day-spark')) {
      updatedBadges.add('3-day-spark');
    }
    if (newLevel >= 10 && !updatedBadges.contains('7-day-flame')) {
      updatedBadges.add('7-day-flame');
    }
    if (newLevel >= 25 && !updatedBadges.contains('level-25-vanguard')) {
      updatedBadges.add('level-25-vanguard');
    }
    if (newLevel >= 50 && !updatedBadges.contains('level-50-master')) {
      updatedBadges.add('level-50-master');
    }

    await _storage.setUnlockedBadges(updatedBadges);

    state = state.copyWith(
      totalXp: newXp,
      level: newLevel,
      unlockedBadgeSlugs: updatedBadges,
    );
  }

  Future<void> unlockBadge(String slug) async {
    if (!state.unlockedBadgeSlugs.contains(slug)) {
      final updated = List<String>.from(state.unlockedBadgeSlugs)..add(slug);
      await _storage.setUnlockedBadges(updated);
      state = state.copyWith(unlockedBadgeSlugs: updated);
    }
  }

  Future<void> setActiveChallenge(String slug) async {
    await _storage.setActiveChallenge(slug);
    state = state.copyWith(activeChallengeSlug: slug);
  }
}

final gamificationNotifierProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);
