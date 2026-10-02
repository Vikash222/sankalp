import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../../quiz/data/models/quiz_models.dart';
import '../../../quiz/data/quiz_repository.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  final QuizSubmitResultModel? initialResult;

  const RoadmapScreen({super.key, this.initialResult});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  RoadmapModel? _roadmap;
  String _archetype = 'Disciplined Architect';
  double _lifeBalanceIndex = 65.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialResult != null) {
      _roadmap = widget.initialResult!.roadmap;
      _archetype = widget.initialResult!.archetype;
      _lifeBalanceIndex = widget.initialResult!.lifeBalanceIndex;
    } else {
      _fetchRoadmap();
    }
  }

  Future<void> _fetchRoadmap() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(quizRepositoryProvider);
      final roadmap = await repo.getCurrentRoadmap();
      setState(() {
        _roadmap = roadmap;
        _archetype = roadmap.tier;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Personalized Roadmap',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SankalpTheme.brandYellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Diagnosis Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SankalpTheme.brandYellow.withValues(alpha: 0.25),
                          SankalpTheme.brandYellow.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SankalpTheme.brandYellow.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ARCHETYPE DIAGNOSIS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Color(0xFF946A00),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_lifeBalanceIndex.toStringAsFixed(0)}% Balance',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _archetype,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your baseline evaluation indicates strong potential. Consistency in the first 21 days is critical to cement automatic neurological triggers.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Transformation Curriculum',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  // Phase Cards
                  if (_roadmap != null && _roadmap!.phases.isNotEmpty)
                    ..._roadmap!.phases.map((phase) => _buildPhaseCard(phase))
                  else ...[
                    _buildFallbackPhase(1, 'Phase 1: Foundation & Dopamine Reset', '14 Days', true),
                    _buildFallbackPhase(2, 'Phase 2: Routine Solidification', '21 Days', false),
                    _buildFallbackPhase(3, 'Phase 3: Identity & Master Discipline', '30 Days', false),
                  ],

                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: () => context.go('/app/today'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Lock In & Begin Today',
                        maxLines: 1,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPhaseCard(RoadmapPhaseModel phase) {
    final isUnlocked = phase.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? SankalpTheme.brandYellow
              : Theme.of(context).dividerColor.withValues(alpha: 0.15),
          width: isUnlocked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? SankalpTheme.brandYellow.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Icon(
              isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              size: 20,
              color: isUnlocked ? const Color(0xFF946A00) : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PHASE ${phase.phaseNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? const Color(0xFF946A00) : Colors.grey,
                      ),
                    ),
                    Text(
                      '${phase.durationDays} Days',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phase.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  phase.focus,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPhase(int num, String title, String duration, bool unlocked) {
    return _buildPhaseCard(
      RoadmapPhaseModel(
        id: num,
        phaseNumber: num,
        title: title,
        focus: 'Structured behavioral habit stacking for consistent progress.',
        durationDays: num == 1 ? 14 : (num == 2 ? 21 : 30),
        isUnlocked: unlocked,
      ),
    );
  }
}
