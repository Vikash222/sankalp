import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arclife/core/network/dio_client.dart';
import 'package:arclife/core/storage/token_storage.dart';
import 'package:arclife/features/quiz/data/quiz_repository.dart';

void main() {
  late TokenStorage tokenStorage;
  late DioClient dioClient;
  late QuizRepository quizRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenStorage = await TokenStorage.create();
    dioClient = DioClient(tokenStorage: tokenStorage);
    quizRepository = QuizRepository(dioClient);
  });

  group('QuizRepository Offline-First & Resiliency Unit Tests', () {
    test('getQuestions returns 16 bundled clinical questions when network times out', () async {
      // Act
      final questions = await quizRepository.getQuestions();

      // Assert
      expect(questions.length, equals(16));
      expect(questions.first.dimension, equals('sleep'));
      expect(questions.first.options.length, equals(4));
      expect(questions.last.dimension, equals('mindset'));
    });

    test('submitQuiz calculates clinical archetype and generates roadmap offline', () async {
      // Arrange 16 answers with highest scores (4 points each = 64 total = 100%)
      final answers = List.generate(
        16,
        (index) => {'question_id': index + 1, 'option_id': (index * 4) + 4},
      );

      // Act
      final result = await quizRepository.submitQuiz(answers);

      // Assert
      expect(result.lifeBalanceIndex, equals(100.0));
      expect(result.archetype, equals('Master Ascendant'));
      expect(result.targetChallengeSlug, equals('90-day-transformation'));
      expect(result.roadmap.phases.length, equals(3));
      expect(result.roadmap.phases.first.isUnlocked, isTrue);
    });

    test('submitQuiz calculates burnout tier when scores are low', () async {
      // Arrange 16 answers with lowest score (1 point each = 16 total = 25%)
      final answers = List.generate(
        16,
        (index) => {'question_id': index + 1, 'option_id': (index * 4) + 1},
      );

      // Act
      final result = await quizRepository.submitQuiz(answers);

      // Assert
      expect(result.lifeBalanceIndex, equals(25.0));
      expect(result.archetype, equals('Dopamine Burnout'));
      expect(result.targetChallengeSlug, equals('21-day-habit-builder'));
    });

    test('getCurrentRoadmap returns valid default roadmap when server is unreachable', () async {
      // Act
      final roadmap = await quizRepository.getCurrentRoadmap();

      // Assert
      expect(roadmap.phases.length, equals(3));
      expect(roadmap.isActive, isTrue);
    });
  });
}
