import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../data/models/quiz_models.dart';
import '../../data/quiz_repository.dart';

class OnboardingQuizScreen extends ConsumerStatefulWidget {
  const OnboardingQuizScreen({super.key});

  @override
  ConsumerState<OnboardingQuizScreen> createState() => _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends ConsumerState<OnboardingQuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionId -> optionId
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<QuizQuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(quizRepositoryProvider);
      final questions = await repo.getQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all 16 questions to calibrate your roadmap.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final answers = _selectedAnswers.entries
          .map((e) => {'question_id': e.key, 'option_id': e.value})
          .toList();

      final repo = ref.read(quizRepositoryProvider);
      final result = await repo.submitQuiz(answers);

      final storage = ref.read(tokenStorageProvider);
      await storage.setCompletedQuiz(true);

      if (mounted) {
        context.go('/roadmap', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evaluation failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SankalpAppBar(
        title: 'Diagnostic Assessment',
        showBackButton: false,
        actions: [
          TextButton(
            onPressed: () => context.push('/auth/login'),
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: SankalpTheme.brandYellow),
            SizedBox(height: 16),
            Text(
              'Calibrating lifestyle assessment...',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchQuestions,
                child: const Text('Retry Calibration'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available.'));
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final selectedOptionId = _selectedAnswers[question.id];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Telemetry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SankalpTheme.brandYellow.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.dimension.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF946A00),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(SankalpTheme.brandYellow),
              ),
            ),
            const SizedBox(height: 24),

            // Question Text
            Text(
              question.questionEn,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = selectedOptionId == option.id;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[question.id] = option.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SankalpTheme.brandYellow.withValues(alpha: 0.15)
                            : Theme.of(context).cardTheme.color,
                        border: Border.all(
                          color: isSelected
                              ? SankalpTheme.brandYellow
                              : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? SankalpTheme.brandYellow
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: isSelected
                                  ? SankalpTheme.brandYellow
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.black)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option.optionEn,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Buttons
            const SizedBox(height: 12),
            Row(
              children: [
                if (_currentIndex > 0) ...[
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _currentIndex--);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting || selectedOptionId == null
                        ? null
                        : () {
                            if (_currentIndex < _questions.length - 1) {
                              setState(() => _currentIndex++);
                            } else {
                              _submitQuiz();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _currentIndex == _questions.length - 1
                                  ? 'Generate Roadmap'
                                  : 'Continue',
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
