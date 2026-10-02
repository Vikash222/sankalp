class UserModel {
  final int id;
  final String uuid;
  final String name;
  final String? email;
  final bool isGuest;
  final int totalXp;
  final UserProfileModel? profile;

  const UserModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.email,
    required this.isGuest,
    this.totalXp = 0,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? 'Practitioner',
      email: json['email'] as String?,
      isGuest: json['is_guest'] as bool? ?? false,
      totalXp: json['total_xp'] as int? ?? 0,
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserProfileModel {
  final double weightKg;
  final double heightCm;
  final String language;
  final String theme;
  final String timezone;
  final int dailyWaterTargetMl;
  final int screenTimeTargetMin;

  const UserProfileModel({
    this.weightKg = 70.0,
    this.heightCm = 175.0,
    this.language = 'en',
    this.theme = 'day',
    this.timezone = 'Asia/Kolkata',
    this.dailyWaterTargetMl = 3000,
    this.screenTimeTargetMin = 120,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 175.0,
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'day',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      dailyWaterTargetMl: json['daily_water_target_ml'] as int? ?? 3000,
      screenTimeTargetMin: json['screen_time_target_min'] as int? ?? 120,
    );
  }
}
