import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/sync/offline_sync_engine.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../../../core/widgets/startup_permission_setup_dialog.dart';
import '../../../activity_tracker/data/datasources/activity_native_bridge.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../gamification/presentation/providers/gamification_notifier.dart';
import '../../domain/entities/habit_model.dart';
import '../providers/habits_notifier.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final ActivityNativeBridge _activityBridge = ActivityNativeBridge();
  final int _freezeCount = 1;
  int _dailyXpEarned = 0;
  String? _lastLoadedChallengeSlug;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupPermissionSetupDialog.checkAndShow(context, bridge: _activityBridge);
    });
  }

  int get _currentStreak {
    final habits = ref.watch(habitsNotifierProvider).activeHabits;
    if (habits.isEmpty) return 0;
    return habits.fold<int>(0, (max, h) => h.currentStreak > max ? h.currentStreak : max);
  }

  List<Map<String, dynamic>> _challengeTasks = [];

  Map<String, dynamic> _getChallengeConfig(String slug) {
    return switch (slug) {
      'summer-arc' => {
          'title': 'Summer Arc: Vitality & Energy',
          'tasks': [
            {'id': 201, 'title': '45-Min Outdoor Walk / Exercise', 'detail': 'Fresh air movement to elevate energy and discipline.', 'xp': 150, 'is_completed': false},
            {'id': 202, 'title': '3.5 Liters Hydration Target', 'detail': 'Electrolytes + cold water throughout the day.', 'xp': 60, 'is_completed': false},
            {'id': 203, 'title': 'High-Protein Clean Nutrition', 'detail': 'Zero processed foods, high micronutrient density.', 'xp': 80, 'is_completed': false},
            {'id': 204, 'title': 'Cold Water Immersion', 'detail': 'Morning cold shower for mitochondrial stimulation.', 'xp': 70, 'is_completed': false},
          ],
        },
      'winter-arc' => {
          'title': 'Winter Arc: Monk Mode',
          'tasks': [
            {'id': 301, 'title': '5:00 AM Cold Shower & Wakeup', 'detail': 'Wake up immediately without hesitation or snooze.', 'xp': 120, 'is_completed': false},
            {'id': 302, 'title': '90-Minute Focus Deep Work', 'detail': 'Zero notifications, total flow block.', 'xp': 150, 'is_completed': false},
            {'id': 303, 'title': 'Heavy Resistance Gym Session', 'detail': '45+ minutes of progressive overload.', 'xp': 120, 'is_completed': false},
            {'id': 304, 'title': 'Dopamine Fast: No Doomscrolling', 'detail': 'Keep social apps completely locked.', 'xp': 100, 'is_completed': false},
          ],
        },
      '90-day-transformation' => {
          'title': '90-Day Complete Overhaul',
          'tasks': [
            {'id': 401, 'title': 'Dopamine Reset: No Short-form Videos', 'detail': 'Break the continuous hyper-stimulation cycle.', 'xp': 100, 'is_completed': false},
            {'id': 402, 'title': '10,000 Steps Daily Movement', 'detail': 'Consistent daily non-exercise physical activity.', 'xp': 100, 'is_completed': false},
            {'id': 403, 'title': '2 Hours Disciplined Skill Practice', 'detail': 'Coding, writing, or studying core craft.', 'xp': 150, 'is_completed': false},
            {'id': 404, 'title': 'Nightly Gratitude & Stoic Journal', 'detail': '10 pages reading and reflection review.', 'xp': 50, 'is_completed': false},
          ],
        },
      _ => {
          'title': '21-Day Habit Builder',
          'tasks': [
            {'id': 101, 'title': 'Morning Sunlight & Hydration', 'detail': 'Drink 500ml water and get 15 mins of natural sunlight.', 'xp': 50, 'is_completed': false},
            {'id': 102, 'title': 'Physical Movement & Workout', 'detail': '30+ minutes of daily workout, stretching, or brisk walk.', 'xp': 100, 'is_completed': false},
            {'id': 103, 'title': 'Zero Social Media Before Noon', 'detail': 'Keep Instagram and YouTube Shorts blocked until noon.', 'xp': 75, 'is_completed': false},
            {'id': 104, 'title': 'Evening Reflection & 10 Pages Reading', 'detail': 'Log mindful reflection and read 10 non-fiction pages.', 'xp': 50, 'is_completed': false},
          ],
        },
    };
  }

  void _syncTasksWithChallenge(String currentSlug) {
    if (_lastLoadedChallengeSlug != currentSlug) {
      _lastLoadedChallengeSlug = currentSlug;
      final config = _getChallengeConfig(currentSlug);
      _challengeTasks = List<Map<String, dynamic>>.from(
        (config['tasks'] as List).map((t) => Map<String, dynamic>.from(t as Map)),
      );
    }
  }

  void _toggleTask(int index) {
    setState(() {
      final wasCompleted = _challengeTasks[index]['is_completed'] as bool;
      _challengeTasks[index]['is_completed'] = !wasCompleted;
      final xp = _challengeTasks[index]['xp'] as int;

      if (!wasCompleted) {
        _dailyXpEarned += xp;
        ref.read(gamificationNotifierProvider.notifier).addXp(xp);
        ref.read(offlineSyncEngineProvider).enqueueHabitCheckIn(
              habitId: _challengeTasks[index]['id'] as int,
              date: DateTime.now().toIso8601String().substring(0, 10),
              completed: true,
            );
        _showXpSnackbar(xp, _challengeTasks[index]['title'] as String);
      } else {
        _dailyXpEarned = (_dailyXpEarned - xp).clamp(0, 9999);
      }
    });
  }

  void _showXpSnackbar(int xp, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: SankalpTheme.brandYellow),
            const SizedBox(width: 8),
            Text('+$xp XP earned for completing $title!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCustomiseHabitModal([HabitModel? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    HabitCategory selectedCategory = existing?.category ?? HabitCategory.fitness;
    HabitTimeOfDay selectedTimeOfDay = existing?.timeOfDay ?? HabitTimeOfDay.morning;
    int xpReward = existing?.xpReward ?? 20;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing != null ? 'Edit Habit' : 'Customise New Habit',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (existing != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () {
                            ref.read(habitsNotifierProvider.notifier).deleteHabit(existing.id);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Habit deleted.'), behavior: SnackBarBehavior.floating),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Habit Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Habit Title',
                      hintText: 'e.g. 20-Minute Meditation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Why this habit matters for your life',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: HabitCategory.values.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat.displayName),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedCategory = cat);
                        },
                        selectedColor: SankalpTheme.brandYellow,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Time of Day Selector
                  const Text('Time of Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: HabitTimeOfDay.values.map((time) {
                      final isSelected = selectedTimeOfDay == time;
                      return ChoiceChip(
                        label: Text('${time.emoji} ${time.displayName}'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedTimeOfDay = time);
                        },
                        selectedColor: SankalpTheme.brandYellow,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // XP Reward
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('XP Reward on Completion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('+$xpReward XP', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF946A00))),
                    ],
                  ),
                  Slider(
                    value: xpReward.toDouble(),
                    min: 10,
                    max: 50,
                    divisions: 8,
                    activeColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setModalState(() => xpReward = val.toInt()),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;

                      final notifier = ref.read(habitsNotifierProvider.notifier);
                      if (existing != null) {
                        notifier.editHabit(
                          id: existing.id,
                          title: title,
                          description: descCtrl.text.trim(),
                          category: selectedCategory,
                          timeOfDay: selectedTimeOfDay,
                          xpReward: xpReward,
                        );
                      } else {
                        notifier.addHabit(
                          title: title,
                          description: descCtrl.text.trim(),
                          category: selectedCategory,
                          timeOfDay: selectedTimeOfDay,
                          xpReward: xpReward,
                        );
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(existing != null ? 'Habit updated successfully.' : 'New habit "$title" added to daily tracker!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SankalpTheme.brandYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      existing != null ? 'Save Changes' : 'Create Custom Habit',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final gamification = ref.watch(gamificationNotifierProvider);
    final habitsState = ref.watch(habitsNotifierProvider);
    final habitsNotifier = ref.read(habitsNotifierProvider.notifier);
    final userName = user?.name ?? 'Practitioner';

    _syncTasksWithChallenge(gamification.activeChallengeSlug);
    final challengeConfig = _getChallengeConfig(gamification.activeChallengeSlug);
    final challengeTitle = challengeConfig['title'] as String;

    return Scaffold(
      appBar: SankalpAppBar(
        title: 'Today',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Habit Calendar',
            onPressed: () => context.push('/habits/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Protocols & Routines',
            onPressed: () => context.push('/habits/routines'),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'Ask AI Coach',
            onPressed: () => context.push('/ai-coach'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting & Motivation
            Text(
              'Good day, $userName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Discipline is your commitment to who you are becoming.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (ref.watch(authNotifierProvider).isGuest) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SankalpTheme.brandYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SankalpTheme.brandYellow.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF946A00)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Guest Mode: Register your account to save habits, routines, and XP progress.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF946A00))),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Streak & XP Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC727),
                    Color(0xFFF7B500),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC727).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 34,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_currentStreak DAY STREAK',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_freezeCount Freezes active • $_dailyXpEarned XP gained today',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Daily Protocols & Routine Card
            InkWell(
              onTap: () => context.push('/habits/routines'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E24AA).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8E24AA), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Daily Protocols & Routines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Morning Monk & Evening routines • +100 bonus XP', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Quick Action Triggers
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add_task_rounded,
                    title: 'Add Habit',
                    onTap: () => _showCustomiseHabitModal(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.timer_outlined,
                    title: 'Deep Work',
                    onTap: () => context.go('/app/detox'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.calendar_month_rounded,
                    title: 'Calendar',
                    onTap: () => context.push('/habits/calendar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.auto_awesome,
                    title: 'AI Mentor',
                    onTap: () => context.push('/ai-coach'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Challenge Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE REGIMEN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF946A00),
                        ),
                      ),
                      Text(
                        challengeTitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/app/challenges'),
                  child: const Text('Change Arc', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF946A00))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_challengeTasks.length, (index) {
              final task = _challengeTasks[index];
              final isDone = task['is_completed'] as bool;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: IconButton(
                    icon: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isDone ? SankalpTheme.brandYellow : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () => _toggleTask(index),
                  ),
                  title: Text(
                    task['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    task['detail'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.grey.withValues(alpha: 0.1)
                          : SankalpTheme.brandYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${task['xp']} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.grey : const Color(0xFF946A00),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Daily Habits Section (Customizable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habit Tracker',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(habitsState.todayCompletionRate * 100).toInt()}% completed today',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCustomiseHabitModal(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('+ Add Habit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: SankalpTheme.brandYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...habitsState.activeHabits.map((habit) {
              final isDone = habit.isCompletedToday();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: GestureDetector(
                    onTap: () => habitsNotifier.toggleHabitCompletion(habit.id),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? SankalpTheme.brandYellow : Colors.transparent,
                        border: Border.all(
                          color: isDone ? SankalpTheme.brandYellow : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded, size: 18, color: Colors.black)
                          : null,
                    ),
                  ),
                  title: Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${habit.currentStreak} Day Streak • ${habit.category.displayName} • +${habit.xpReward} XP',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(habit.timeOfDay.emoji, style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                        tooltip: 'Edit Habit',
                        onPressed: () => _showCustomiseHabitModal(habit),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF946A00)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
