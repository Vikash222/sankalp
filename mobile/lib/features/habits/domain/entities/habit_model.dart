enum HabitCategory {
  fitness('Fitness', 0xFFE53935),
  mindset('Mindset', 0xFF8E24AA),
  focus('Focus', 0xFF1E88E5),
  health('Health', 0xFF43A047),
  nutrition('Nutrition', 0xFFFB8C00),
  custom('Custom', 0xFFFFC727);

  final String displayName;
  final int colorValue;
  const HabitCategory(this.displayName, this.colorValue);

  static HabitCategory fromString(String val) {
    return HabitCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.displayName.toLowerCase() == val.toLowerCase(),
      orElse: () => HabitCategory.custom,
    );
  }
}

enum HabitTimeOfDay {
  morning('Morning', '🌅'),
  afternoon('Afternoon', '☀️'),
  evening('Evening', '🌙'),
  anytime('Anytime', '⚡');

  final String displayName;
  final String emoji;
  const HabitTimeOfDay(this.displayName, this.emoji);

  static HabitTimeOfDay fromString(String val) {
    return HabitTimeOfDay.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.displayName.toLowerCase() == val.toLowerCase(),
      orElse: () => HabitTimeOfDay.anytime,
    );
  }
}

class HabitModel {
  final int id;
  final String title;
  final String description;
  final HabitCategory category;
  final HabitTimeOfDay timeOfDay;
  final int xpReward;
  final int currentStreak;
  final int bestStreak;
  final List<String> completedDates; // YYYY-MM-DD
  final String? reminderTime; // e.g. "07:00"
  final bool isArchived;

  const HabitModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.timeOfDay = HabitTimeOfDay.anytime,
    this.xpReward = 20,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completedDates = const [],
    this.reminderTime,
    this.isArchived = false,
  });

  bool isCompletedOn(String dateStr) {
    return completedDates.contains(dateStr);
  }

  bool isCompletedToday() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return isCompletedOn(todayStr);
  }

  HabitModel copyWith({
    int? id,
    String? title,
    String? description,
    HabitCategory? category,
    HabitTimeOfDay? timeOfDay,
    int? xpReward,
    int? currentStreak,
    int? bestStreak,
    List<String>? completedDates,
    String? reminderTime,
    bool? isArchived,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      xpReward: xpReward ?? this.xpReward,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'time_of_day': timeOfDay.name,
      'xp_reward': xpReward,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'completed_dates': completedDates,
      'reminder_time': reminderTime,
      'is_archived': isArchived,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: HabitCategory.fromString(json['category'] as String? ?? 'custom'),
      timeOfDay: HabitTimeOfDay.fromString(json['time_of_day'] as String? ?? 'anytime'),
      xpReward: json['xp_reward'] as int? ?? 20,
      currentStreak: json['current_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      completedDates: (json['completed_dates'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reminderTime: json['reminder_time'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }
}

class RoutineStep {
  final String title;
  final int durationMinutes;
  final bool isCompleted;

  const RoutineStep({
    required this.title,
    this.durationMinutes = 5,
    this.isCompleted = false,
  });

  RoutineStep copyWith({
    String? title,
    int? durationMinutes,
    bool? isCompleted,
  }) {
    return RoutineStep(
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'duration_minutes': durationMinutes,
        'is_completed': isCompleted,
      };

  factory RoutineStep.fromJson(Map<String, dynamic> json) => RoutineStep(
        title: json['title'] as String,
        durationMinutes: json['duration_minutes'] as int? ?? 5,
        isCompleted: json['is_completed'] as bool? ?? false,
      );
}

class RoutineModel {
  final String id;
  final String title;
  final String time; // e.g. "06:30 AM"
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final List<RoutineStep> steps;
  final bool isNotificationEnabled;
  final int xpBonus;
  final String? lastCompletedDate;

  const RoutineModel({
    required this.id,
    required this.title,
    required this.time,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    required this.steps,
    this.isNotificationEnabled = true,
    this.xpBonus = 100,
    this.lastCompletedDate,
  });

  bool isCompletedToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastCompletedDate == today;
  }

  int get totalMinutes => steps.fold(0, (acc, s) => acc + s.durationMinutes);

  int get completedStepsCount => steps.where((s) => s.isCompleted).length;

  RoutineModel copyWith({
    String? id,
    String? title,
    String? time,
    List<int>? daysOfWeek,
    List<RoutineStep>? steps,
    bool? isNotificationEnabled,
    int? xpBonus,
    String? lastCompletedDate,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      steps: steps ?? this.steps,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      xpBonus: xpBonus ?? this.xpBonus,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'days_of_week': daysOfWeek,
        'steps': steps.map((s) => s.toJson()).toList(),
        'is_notification_enabled': isNotificationEnabled,
        'xp_bonus': xpBonus,
        'last_completed_date': lastCompletedDate,
      };

  factory RoutineModel.fromJson(Map<String, dynamic> json) => RoutineModel(
        id: json['id'] as String,
        title: json['title'] as String,
        time: json['time'] as String,
        daysOfWeek: (json['days_of_week'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5, 6, 7],
        steps: (json['steps'] as List<dynamic>?)?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        isNotificationEnabled: json['is_notification_enabled'] as bool? ?? true,
        xpBonus: json['xp_bonus'] as int? ?? 100,
        lastCompletedDate: json['last_completed_date'] as String?,
      );
}
