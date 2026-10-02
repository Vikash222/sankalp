class QuizQuestionModel {
  final int id;
  final String dimension;
  final int orderNumber;
  final String questionEn;
  final String questionHi;
  final List<QuizOptionModel> options;

  const QuizQuestionModel({
    required this.id,
    required this.dimension,
    required this.orderNumber,
    required this.questionEn,
    required this.questionHi,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>?)
            ?.map((e) => QuizOptionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return QuizQuestionModel(
      id: json['id'] as int? ?? 0,
      dimension: json['dimension'] as String? ?? 'general',
      orderNumber: json['order_number'] as int? ?? 1,
      questionEn: json['question_en'] as String? ?? '',
      questionHi: json['question_hi'] as String? ?? '',
      options: opts,
    );
  }
}

class QuizOptionModel {
  final int id;
  final int scorePoints;
  final String optionEn;
  final String optionHi;

  const QuizOptionModel({
    required this.id,
    required this.scorePoints,
    required this.optionEn,
    required this.optionHi,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'] as int? ?? 0,
      scorePoints: json['score_points'] as int? ?? 1,
      optionEn: json['option_en'] as String? ?? '',
      optionHi: json['option_hi'] as String? ?? '',
    );
  }
}

class RoadmapPhaseModel {
  final int id;
  final int phaseNumber;
  final String title;
  final String focus;
  final int durationDays;
  final bool isUnlocked;

  const RoadmapPhaseModel({
    required this.id,
    required this.phaseNumber,
    required this.title,
    required this.focus,
    required this.durationDays,
    required this.isUnlocked,
  });

  factory RoadmapPhaseModel.fromJson(Map<String, dynamic> json) {
    return RoadmapPhaseModel(
      id: json['id'] as int? ?? 0,
      phaseNumber: json['phase_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 30,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
    );
  }
}

class RoadmapModel {
  final int id;
  final String title;
  final String tier;
  final String targetChallengeSlug;
  final bool isActive;
  final List<RoadmapPhaseModel> phases;

  const RoadmapModel({
    required this.id,
    required this.title,
    required this.tier,
    required this.targetChallengeSlug,
    required this.isActive,
    required this.phases,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final phasesList = (json['phases'] as List<dynamic>?)
            ?.map((e) => RoadmapPhaseModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return RoadmapModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      tier: json['tier'] as String? ?? '',
      targetChallengeSlug: json['target_challenge_slug'] as String? ?? '21-day-habit-builder',
      isActive: json['is_active'] as bool? ?? true,
      phases: phasesList,
    );
  }
}

class QuizSubmitResultModel {
  final String archetype;
  final double lifeBalanceIndex;
  final String targetChallengeSlug;
  final RoadmapModel roadmap;

  const QuizSubmitResultModel({
    required this.archetype,
    required this.lifeBalanceIndex,
    required this.targetChallengeSlug,
    required this.roadmap,
  });

  factory QuizSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResultModel(
      archetype: json['archetype'] as String? ?? 'Disciplined Architect',
      lifeBalanceIndex: (json['life_balance_index'] as num?)?.toDouble() ?? 50.0,
      targetChallengeSlug: json['target_challenge_slug'] as String? ?? '21-day-habit-builder',
      roadmap: RoadmapModel.fromJson(json['roadmap'] as Map<String, dynamic>),
    );
  }
}
