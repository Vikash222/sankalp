import 'package:flutter/material.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';

class LevelInfo {
  final int level;
  final String title;
  final int xpRequired;
  final String perk;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.xpRequired,
    required this.perk,
  });
}

class LevelsProgressionScreen extends StatelessWidget {
  const LevelsProgressionScreen({super.key});

  final int currentLevel = 7;
  final int currentXp = 1420;

  List<LevelInfo> _generateLevels() {
    return const [
      LevelInfo(level: 1, title: 'The Awakening', xpRequired: 0, perk: 'Basic habit check-ins and today checklist unlocked.'),
      LevelInfo(level: 2, title: 'First Momentum', xpRequired: 150, perk: 'Streak freeze slot #1 activated.'),
      LevelInfo(level: 3, title: 'Routine Seeker', xpRequired: 350, perk: 'Unlocked Pomodoro 15m focus sessions.'),
      LevelInfo(level: 4, title: 'Steadfast Novice', xpRequired: 650, perk: 'AI Sankalp Coach prompt suggestion chips.'),
      LevelInfo(level: 5, title: 'Iron Initiate', xpRequired: 1000, perk: 'Custom Accent Color Theme Mode unlocked!'),
      LevelInfo(level: 6, title: 'Consistent Striver', xpRequired: 1350, perk: 'Detailed kilometer split analysis for outdoor GPS workouts.'),
      LevelInfo(level: 7, title: 'Disciplino', xpRequired: 1800, perk: 'Streak freeze slot #2 activated.'),
      LevelInfo(level: 8, title: 'Habit Architect', xpRequired: 2350, perk: 'Audio pace and distance cues (TTS) during workouts.'),
      LevelInfo(level: 9, title: 'Mindful Guardian', xpRequired: 3000, perk: 'Extended deep work 45m Pomodoro sessions.'),
      LevelInfo(level: 10, title: 'Pillar of Resolve', xpRequired: 3750, perk: 'Advanced Weekly Discipline Mileage Progression Chart.'),
      LevelInfo(level: 15, title: 'Relentless Vanguard', xpRequired: 8500, perk: 'Custom Challenge Creator with daily rule editor.'),
      LevelInfo(level: 20, title: 'Stoic Warrior', xpRequired: 15000, perk: 'Night Wind-Down binaural focus timer unlocked.'),
      LevelInfo(level: 25, title: 'Master of Focus', xpRequired: 24000, perk: 'Hardcore Strict App Blocker mode unlocked.'),
      LevelInfo(level: 30, title: 'Iron Monk', xpRequired: 36000, perk: 'Prestige Diamond Avatar Frame on Leaderboards.'),
      LevelInfo(level: 40, title: 'Transcendent Stoic', xpRequired: 68000, perk: 'Lifetime Streak Immortal Vault status.'),
      LevelInfo(level: 50, title: 'Sovereign Master', xpRequired: 120000, perk: 'The Ultimate Discipline Tier. Legend of Sankalp.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final levels = _generateLevels();
    const nextLevelXp = 1800;
    const progress = (1420 - 1350) / (nextLevelXp - 1350);

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Level Progression',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Current Level Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC727), Color(0xFFF7B500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC727).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEVEL $currentLevel',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Disciplino',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$currentXp XP',
                        style: const TextStyle(
                          color: Color(0xFFFFC727),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.black.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress to Level 8: Habit Architect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('${nextLevelXp - currentXp} XP to go', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),

          // Levels Timeline
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: levels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lvl = levels[index];
                final isReached = lvl.level <= currentLevel;
                final isCurrent = lvl.level == currentLevel;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? SankalpTheme.brandYellow
                          : (isReached ? Colors.green.withValues(alpha: 0.4) : Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReached
                              ? SankalpTheme.brandYellow.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isReached ? const Color(0xFF946A00) : Colors.grey.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${lvl.level}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isReached ? const Color(0xFF946A00) : Colors.grey,
                            ),
                          ),
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
                                  lvl.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isReached ? null : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${lvl.xpRequired} XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isReached ? const Color(0xFF946A00) : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lvl.perk,
                              style: TextStyle(
                                fontSize: 13,
                                color: isReached ? Colors.grey[700] : Colors.grey[500],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
