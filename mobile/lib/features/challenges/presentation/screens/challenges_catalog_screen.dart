import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../../gamification/presentation/providers/gamification_notifier.dart';

class ChallengesCatalogScreen extends ConsumerWidget {
  const ChallengesCatalogScreen({super.key});

  final List<Map<String, dynamic>> _challenges = const [
    {
      'slug': '21-day-habit-builder',
      'title': '21-Day Habit Builder',
      'days': 21,
      'difficulty': 'Beginner',
      'tag': 'RECOMMENDED START',
      'description': 'Establish bedrock foundational discipline: morning sunlight, zero night-time scrolling, 3L water, and daily movement.',
      'accent': Color(0xFFFFC727),
      'icon': Icons.bolt_rounded,
    },
    {
      'slug': '90-day-transformation',
      'title': '90-Day Complete Overhaul',
      'days': 90,
      'difficulty': 'Intermediate',
      'tag': 'FULL TRANSFORMATION',
      'description': 'Three distinct phases (Reset: 1-30, Build: 31-60, Lock-in: 61-90) designed to systematically reconstruct your identity.',
      'accent': Color(0xFFFF9800),
      'icon': Icons.military_tech_rounded,
    },
    {
      'slug': 'summer-arc',
      'title': 'Summer Arc: Vitality & Energy',
      'days': 75,
      'difficulty': 'Intermediate',
      'tag': 'PHYSICAL VITALITY',
      'description': 'Peak physical conditioning, daily workouts, hydration targets, clean nutrition, and active movement routines.',
      'accent': Color(0xFF4CAF50),
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'slug': 'winter-arc',
      'title': 'Winter Arc: Monk Mode',
      'days': 90,
      'difficulty': 'Hardcore',
      'tag': 'MAXIMUM DISCIPLINE',
      'description': 'Uncompromising deep work, daily cold exposure, intense workouts, zero dopamine traps, and total mental clarity.',
      'accent': Color(0xFF2196F3),
      'icon': Icons.ac_unit_rounded,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSlug = ref.watch(gamificationNotifierProvider).activeChallengeSlug;

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Challenge Arcs',
        showBackButton: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: _challenges.length,
        itemBuilder: (context, index) {
          final c = _challenges[index];
          final accent = c['accent'] as Color;
          final isEnrolled = activeSlug == c['slug'];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isEnrolled ? accent : accent.withValues(alpha: 0.3),
                width: isEnrolled ? 2.5 : 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEnrolled ? 'CURRENTLY ACTIVE' : (c['tag'] as String),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                      Text(
                        '${c['days']} Days • ${c['difficulty']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.15),
                        ),
                        child: Icon(c['icon'] as IconData, color: accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c['title'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c['description'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(gamificationNotifierProvider.notifier)
                            .setActiveChallenge(c['slug'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Enrolled in ${c['title']}! Day 1 is now active on your dashboard.',
                            ),
                            backgroundColor: Colors.green[800],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        context.go('/app/today');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnrolled ? Colors.black : accent,
                        foregroundColor: isEnrolled ? accent : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isEnrolled ? 'Active Regimen (View Today)' : 'Enroll in Challenge',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
