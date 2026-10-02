import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../providers/gamification_notifier.dart';

class FriendUser {
  final String id;
  final String name;
  final String referralCode;
  final int weeklyXp;
  final int streakDays;
  final bool isGpsVerified;
  final bool isCurrentUser;
  final String city;

  const FriendUser({
    required this.id,
    required this.name,
    required this.referralCode,
    required this.weeklyXp,
    required this.streakDays,
    this.isGpsVerified = true,
    this.isCurrentUser = false,
    this.city = 'New Delhi',
  });

  FriendUser copyWith({
    String? id,
    String? name,
    String? referralCode,
    int? weeklyXp,
    int? streakDays,
    bool? isGpsVerified,
    bool? isCurrentUser,
    String? city,
  }) {
    return FriendUser(
      id: id ?? this.id,
      name: name ?? this.name,
      referralCode: referralCode ?? this.referralCode,
      weeklyXp: weeklyXp ?? this.weeklyXp,
      streakDays: streakDays ?? this.streakDays,
      isGpsVerified: isGpsVerified ?? this.isGpsVerified,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'referral_code': referralCode,
        'weekly_xp': weeklyXp,
        'streak_days': streakDays,
        'is_gps_verified': isGpsVerified,
        'is_current_user': isCurrentUser,
        'city': city,
      };

  factory FriendUser.fromJson(Map<String, dynamic> json) => FriendUser(
        id: json['id'] as String,
        name: json['name'] as String,
        referralCode: json['referral_code'] as String,
        weeklyXp: json['weekly_xp'] as int? ?? 1000,
        streakDays: json['streak_days'] as int? ?? 7,
        isGpsVerified: json['is_gps_verified'] as bool? ?? true,
        isCurrentUser: json['is_current_user'] as bool? ?? false,
        city: json['city'] as String? ?? 'New Delhi',
      );
}

class FriendsLeagueState {
  final String myReferralCode;
  final List<FriendUser> friends;
  final List<String> redeemedCodes;
  final int totalInvites;

  const FriendsLeagueState({
    required this.myReferralCode,
    required this.friends,
    this.redeemedCodes = const [],
    this.totalInvites = 0,
  });

  FriendsLeagueState copyWith({
    String? myReferralCode,
    List<FriendUser>? friends,
    List<String>? redeemedCodes,
    int? totalInvites,
  }) {
    return FriendsLeagueState(
      myReferralCode: myReferralCode ?? this.myReferralCode,
      friends: friends ?? this.friends,
      redeemedCodes: redeemedCodes ?? this.redeemedCodes,
      totalInvites: totalInvites ?? this.totalInvites,
    );
  }
}

class FriendsLeagueNotifier extends Notifier<FriendsLeagueState> {
  static const String _friendsKey = 'sankalp_friends_league';
  static const String _redeemedKey = 'sankalp_redeemed_referral_codes';

  @override
  FriendsLeagueState build() {
    final storage = ref.watch(tokenStorageProvider);
    final uuid = storage.getOrCreateDeviceUuid();
    final codeSeed = uuid.replaceAll('-', '').substring(0, 5).toUpperCase();
    final myCode = 'SANKALP-$codeSeed';

    final state = FriendsLeagueState(
      myReferralCode: myCode,
      friends: _defaultFriends(),
    );

    Future.microtask(() => _loadFromStorage());
    return state;
  }

  Future<void> _loadFromStorage() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final raw = storage.prefs.getString(_friendsKey);
      final rawRedeemed = storage.prefs.getStringList(_redeemedKey) ?? [];

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        final loaded = list.map((e) => FriendUser.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(friends: loaded, redeemedCodes: rawRedeemed);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final raw = jsonEncode(state.friends.map((f) => f.toJson()).toList());
      await storage.prefs.setString(_friendsKey, raw);
      await storage.prefs.setStringList(_redeemedKey, state.redeemedCodes);
    } catch (_) {}
  }

  List<FriendUser> getSortedFriends(int currentUserXp, String currentUserName) {
    final currentUser = FriendUser(
      id: 'me',
      name: '$currentUserName (You)',
      referralCode: state.myReferralCode,
      weeklyXp: currentUserXp,
      streakDays: 19,
      isGpsVerified: true,
      isCurrentUser: true,
      city: 'Local',
    );

    final list = [...state.friends.where((f) => !f.isCurrentUser), currentUser];
    list.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
    return list;
  }

  Future<bool> redeemReferralCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;
    if (cleanCode == state.myReferralCode) return false; // Cannot redeem own code
    if (state.redeemedCodes.contains(cleanCode)) return false; // Already redeemed

    // Add +250 XP bonus
    ref.read(gamificationNotifierProvider.notifier).addXp(250);

    // Auto-create friend from referral
    final friendName = 'Friend (${cleanCode.split('-').last})';
    final newFriend = FriendUser(
      id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
      name: friendName,
      referralCode: cleanCode,
      weeklyXp: 1850,
      streakDays: 14,
      isGpsVerified: true,
      city: 'Jaipur',
    );

    final updatedFriends = [...state.friends, newFriend];
    final updatedRedeemed = [...state.redeemedCodes, cleanCode];

    state = state.copyWith(
      friends: updatedFriends,
      redeemedCodes: updatedRedeemed,
      totalInvites: state.totalInvites + 1,
    );
    await _saveToStorage();
    return true;
  }

  Future<void> addFriendManually({required String name, required String referralCode}) async {
    final newFriend = FriendUser(
      id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      referralCode: referralCode.toUpperCase(),
      weeklyXp: (1200 + (DateTime.now().millisecond % 1500)),
      streakDays: (5 + (DateTime.now().second % 20)),
      isGpsVerified: true,
      city: 'Delhi Circle',
    );

    final updated = [...state.friends, newFriend];
    state = state.copyWith(friends: updated);
    await _saveToStorage();
  }

  static List<FriendUser> _defaultFriends() {
    return const [
      FriendUser(
        id: '1',
        name: 'Kavya Sharma',
        referralCode: 'SANKALP-9B4R',
        weeklyXp: 3420,
        streakDays: 28,
        isGpsVerified: true,
        city: 'Bengaluru',
      ),
      FriendUser(
        id: '2',
        name: 'Rohan Verma',
        referralCode: 'SANKALP-2H7K',
        weeklyXp: 2950,
        streakDays: 21,
        isGpsVerified: true,
        city: 'Mumbai',
      ),
      FriendUser(
        id: '3',
        name: 'Devansh Roy',
        referralCode: 'SANKALP-8M1P',
        weeklyXp: 2100,
        streakDays: 15,
        isGpsVerified: true,
        city: 'Hyderabad',
      ),
      FriendUser(
        id: '4',
        name: 'Isha Patel',
        referralCode: 'SANKALP-4W9Q',
        weeklyXp: 1650,
        streakDays: 9,
        isGpsVerified: true,
        city: 'Ahmedabad',
      ),
    ];
  }
}

final friendsLeagueNotifierProvider =
    NotifierProvider<FriendsLeagueNotifier, FriendsLeagueState>(
  FriendsLeagueNotifier.new,
);
