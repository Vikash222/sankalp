import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../providers/gamification_notifier.dart';

class BadgeItemData {
  final String slug;
  final String title;
  final String category;
  final String description;
  final int xpBonus;
  final String rarity; // Bronze, Silver, Gold, Diamond
  final IconData icon;

  const BadgeItemData({
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    required this.xpBonus,
    required this.rarity,
    required this.icon,
  });

  Color get rarityColor {
    return switch (rarity) {
      'Bronze' => const Color(0xFFCD7F32),
      'Silver' => const Color(0xFFC0C0C0),
      'Gold' => const Color(0xFFFFD700),
      'Diamond' => const Color(0xFF00E5FF),
      _ => SankalpTheme.brandYellow,
    };
  }
}

class BadgesCatalogScreen extends ConsumerStatefulWidget {
  const BadgesCatalogScreen({super.key});

  @override
  ConsumerState<BadgesCatalogScreen> createState() => _BadgesCatalogScreenState();
}

class _BadgesCatalogScreenState extends ConsumerState<BadgesCatalogScreen> {
  String _selectedCategory = 'All';

  final List<BadgeItemData> _badges = const [
    // Discipline & Streaks
    BadgeItemData(slug: 'first-step', title: 'First Step', category: 'Discipline', description: 'Complete your first habit check-in.', xpBonus: 25, rarity: 'Bronze', icon: Icons.check_circle_outline_rounded),
    BadgeItemData(slug: '3-day-spark', title: '3-Day Spark', category: 'Discipline', description: 'Sustain 3 consecutive days of discipline.', xpBonus: 50, rarity: 'Bronze', icon: Icons.bolt_rounded),
    BadgeItemData(slug: '7-day-flame', title: '7-Day Flame', category: 'Discipline', description: 'Complete a full week without breaking streak.', xpBonus: 100, rarity: 'Silver', icon: Icons.local_fire_department_rounded),
    BadgeItemData(slug: '14-day-blaze', title: '14-Day Blaze', category: 'Discipline', description: 'Surpass 2 weeks of consecutive habit check-ins.', xpBonus: 200, rarity: 'Silver', icon: Icons.whatshot_rounded),
    BadgeItemData(slug: '21-day-habit-builder', title: '21-Day Finisher', category: 'Discipline', description: 'Complete the foundational 21-Day Habit Builder challenge.', xpBonus: 350, rarity: 'Gold', icon: Icons.verified_rounded),
    BadgeItemData(slug: '30-day-foundation', title: '30-Day Pillar', category: 'Discipline', description: 'Reach one uninterrupted month of daily practice.', xpBonus: 500, rarity: 'Gold', icon: Icons.castle_rounded),
    BadgeItemData(slug: '60-day-momentum', title: '60-Day Iron', category: 'Discipline', description: 'Lock in two months of disciplined transformation.', xpBonus: 800, rarity: 'Diamond', icon: Icons.shield_rounded),
    BadgeItemData(slug: '90-day-monk', title: '90-Day Monk', category: 'Discipline', description: 'Complete the 90-Day Overhaul transformation challenge.', xpBonus: 1500, rarity: 'Diamond', icon: Icons.military_tech_rounded),

    // Seasonal Arcs
    BadgeItemData(slug: 'summer-arc-champion', title: 'Summer Arc Titan', category: 'Milestones', description: 'Complete the grueling Summer Arc regimen.', xpBonus: 1000, rarity: 'Gold', icon: Icons.wb_sunny_rounded),
    BadgeItemData(slug: 'winter-arc-titan', title: 'Winter Arc Stoic', category: 'Milestones', description: 'Master cold showers, deep work, and discipline in Winter Arc.', xpBonus: 1000, rarity: 'Diamond', icon: Icons.ac_unit_rounded),
    BadgeItemData(slug: 'architect-of-destiny', title: 'Destiny Architect', category: 'Milestones', description: 'Design and complete a custom 30+ day transformation challenge.', xpBonus: 750, rarity: 'Gold', icon: Icons.auto_awesome_rounded),

    // Digital Detox & Deep Work
    BadgeItemData(slug: 'deep-work-initiate', title: 'Focus Initiate', category: 'Detox', description: 'Complete your first 25-minute Pomodoro session.', xpBonus: 50, rarity: 'Bronze', icon: Icons.timer_rounded),
    BadgeItemData(slug: 'flow-master-10h', title: 'Flow Master', category: 'Detox', description: 'Accumulate 10 total hours of deep work focus sessions.', xpBonus: 250, rarity: 'Silver', icon: Icons.hourglass_top_rounded),
    BadgeItemData(slug: 'digital-ascetic-50h', title: 'Digital Ascetic', category: 'Detox', description: 'Surpass 50 hours of distraction-blocked focus time.', xpBonus: 600, rarity: 'Gold', icon: Icons.phonelink_erase_rounded),
    BadgeItemData(slug: 'zero-doomscroll-week', title: 'Doomscroll Slayer', category: 'Detox', description: 'Keep daily screen time under budget for 7 straight days.', xpBonus: 400, rarity: 'Gold', icon: Icons.block_rounded),

    // Fitness & Physical Discipline
    BadgeItemData(slug: 'first-run', title: 'Daily Movement', category: 'Fitness', description: 'Log your first physical exercise or walking workout.', xpBonus: 50, rarity: 'Bronze', icon: Icons.directions_walk_rounded),
    BadgeItemData(slug: '5k-strider', title: 'Cardio Finisher', category: 'Fitness', description: 'Complete 30+ minutes of continuous cardio exercise.', xpBonus: 150, rarity: 'Silver', icon: Icons.fitness_center_rounded),
    BadgeItemData(slug: '10k-endurance', title: 'Fitness Crusher', category: 'Fitness', description: 'Complete 10 high-intensity workout sessions.', xpBonus: 350, rarity: 'Gold', icon: Icons.speed_rounded),
    BadgeItemData(slug: 'half-marathon', title: 'Endurance Beast', category: 'Fitness', description: 'Maintain 21 consecutive days of physical workout activity.', xpBonus: 800, rarity: 'Diamond', icon: Icons.emoji_events_rounded),
    BadgeItemData(slug: 'centurion-cycling', title: 'Century Mover', category: 'Fitness', description: 'Accumulate 100 total days of healthy physical activity.', xpBonus: 500, rarity: 'Gold', icon: Icons.sports_gymnastics_rounded),

    // Mindset, Rest & Health
    BadgeItemData(slug: 'dawn-patrol', title: 'Dawn Patrol', category: 'Mindset', description: 'Complete a morning sunlight or workout check-in before 7:00 AM.', xpBonus: 100, rarity: 'Silver', icon: Icons.wb_twilight_rounded),
    BadgeItemData(slug: 'hydration-hero', title: 'Hydration Hero', category: 'Mindset', description: 'Log 3+ liters of hydration for 14 consecutive days.', xpBonus: 150, rarity: 'Silver', icon: Icons.water_drop_rounded),
    BadgeItemData(slug: 'cold-shower-stoic', title: 'Cold Shower Stoic', category: 'Mindset', description: 'Log 21 consecutive morning cold showers.', xpBonus: 300, rarity: 'Gold', icon: Icons.shower_rounded),
    BadgeItemData(slug: 'evening-journaler', title: 'Mindful Scribe', category: 'Mindset', description: 'Complete 30 daily evening reflection entries.', xpBonus: 300, rarity: 'Gold', icon: Icons.edit_note_rounded),
    BadgeItemData(slug: 'comeback-phoenix', title: 'Phoenix Comeback', category: 'Milestones', description: 'Successfully complete Comeback Mode after a broken streak.', xpBonus: 250, rarity: 'Silver', icon: Icons.volunteer_activism_rounded),
    BadgeItemData(slug: 'century-club', title: 'Century Club', category: 'Milestones', description: 'Log 100 total habit completions across any habits.', xpBonus: 400, rarity: 'Gold', icon: Icons.workspace_premium_rounded),
    BadgeItemData(slug: 'master-mentor', title: 'Mentor Scholar', category: 'Mindset', description: 'Converse with AI Sankalp Coach for 15 insightful sessions.', xpBonus: 200, rarity: 'Silver', icon: Icons.psychology_rounded),
    BadgeItemData(slug: 'level-25-vanguard', title: 'Level 25 Vanguard', category: 'Milestones', description: 'Reach Level 25 in the Discipline XP progression ladder.', xpBonus: 500, rarity: 'Gold', icon: Icons.military_tech_rounded),
    BadgeItemData(slug: 'level-50-master', title: 'Level 50 Sovereign', category: 'Milestones', description: 'Achieve the ultimate rank: Level 50 Sovereign Master.', xpBonus: 2000, rarity: 'Diamond', icon: Icons.diamond_rounded),
    BadgeItemData(slug: 'perfect-month', title: 'Flawless Month', category: 'Milestones', description: 'Complete 100% of daily habits for an entire calendar month.', xpBonus: 1000, rarity: 'Diamond', icon: Icons.stars_rounded),
  ];

  void _showBadgeDetailModal(BadgeItemData badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? badge.rarityColor.withValues(alpha: 0.18)
                      : Colors.grey.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isUnlocked ? badge.rarityColor : Colors.grey.withValues(alpha: 0.3),
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                  size: 38,
                  color: isUnlocked ? badge.rarityColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.rarityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${badge.rarity.toUpperCase()} TIER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badge.rarityColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SankalpTheme.brandYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${badge.xpBonus} Discipline XP Granted',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF946A00)),
                ),
              ),
              const SizedBox(height: 20),
              if (isUnlocked)
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: SankalpTheme.brandYellow,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Unlocked & Active'),
                    ],
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: () {
                    ref.read(gamificationNotifierProvider.notifier).unlockBadge(badge.slug);
                    ref.read(gamificationNotifierProvider.notifier).addXp(badge.xpBonus);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unlocked "${badge.title}" and gained +${badge.xpBonus} XP!'),
                        backgroundColor: Colors.green[800],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SankalpTheme.brandYellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Unlock in Practice Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamificationState = ref.watch(gamificationNotifierProvider);
    final categories = ['All', 'Discipline', 'Fitness', 'Detox', 'Mindset', 'Milestones'];
    final filtered = _selectedCategory == 'All'
        ? _badges
        : _badges.where((b) => b.category == _selectedCategory).toList();

    final unlockedCount = _badges.where((b) => gamificationState.isBadgeUnlocked(b.slug)).length;

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Discipline Badges',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header Stats Banner
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('30 MASTERY BADGES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.0)),
                    const SizedBox(height: 2),
                    Text('$unlockedCount / ${_badges.length} Unlocked', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((unlockedCount / _badges.length) * 100).toInt()}% Done',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF946A00), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Categories Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: SankalpTheme.brandYellow,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.black : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Badges Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final badge = filtered[index];
                final isUnlocked = gamificationState.isBadgeUnlocked(badge.slug);

                return InkWell(
                  onTap: () => _showBadgeDetailModal(badge, isUnlocked),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked
                            ? badge.rarityColor.withValues(alpha: 0.6)
                            : Theme.of(context).dividerColor.withValues(alpha: 0.15),
                        width: isUnlocked ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnlocked
                                ? badge.rarityColor.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                            size: 24,
                            color: isUnlocked ? badge.rarityColor : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.rarity,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isUnlocked ? badge.rarityColor : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
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
