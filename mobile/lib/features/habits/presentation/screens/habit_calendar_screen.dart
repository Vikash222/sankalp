import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../providers/habits_notifier.dart';

/// Interactive Monthly Habit Calendar & History Screen.
/// Allows practitioners to view visual heatmaps of habit completions across past days,
/// inspect daily progress, and retroactively check in or edit habits.
class HabitCalendarScreen extends ConsumerStatefulWidget {
  const HabitCalendarScreen({super.key});

  @override
  ConsumerState<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends ConsumerState<HabitCalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitsNotifierProvider);
    final notifier = ref.read(habitsNotifierProvider.notifier);
    final selectedDate = habitsState.selectedDate;
    final selectedDateStr = selectedDate.toIso8601String().substring(0, 10);

    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = _focusedMonth.weekday; // 1 = Mon, 7 = Sun

    // Calculate monthly stats
    int totalCheckInsThisMonth = 0;
    int perfectDaysCount = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final completed = habitsState.activeHabits.where((h) => h.isCompletedOn(date.toIso8601String().substring(0, 10))).length;
      if (completed > 0) totalCheckInsThisMonth += completed;
      if (completed == habitsState.activeHabits.length && habitsState.activeHabits.isNotEmpty) {
        perfectDaysCount++;
      }
    }

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthTitle = '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Habit Calendar',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Monthly Highlights Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC727), Color(0xFFF7B500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC727).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Total Check-ins', '$totalCheckInsThisMonth', Icons.check_circle_outline_rounded),
                  Container(width: 1, height: 36, color: Colors.black12),
                  _buildStatColumn('Perfect Days', '$perfectDaysCount', Icons.stars_rounded),
                  Container(width: 1, height: 36, color: Colors.black12),
                  _buildStatColumn('Active Habits', '${habitsState.activeHabits.length}', Icons.bolt_rounded),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Calendar Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  // Month Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _previousMonth,
                        tooltip: 'Previous Month',
                      ),
                      Text(
                        monthTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: _nextMonth,
                        tooltip: 'Next Month',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Weekday Names
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _WeekdayLabel('M'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('W'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('F'),
                      _WeekdayLabel('S'),
                      _WeekdayLabel('S'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Days Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: (firstWeekday - 1) + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday - 1) {
                        return const SizedBox.shrink();
                      }

                      final dayNum = index - (firstWeekday - 1) + 1;
                      final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                      final dateStr = date.toIso8601String().substring(0, 10);
                      final isSelected = date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      final isFuture = date.isAfter(DateTime.now());

                      final completedCount = habitsState.activeHabits.where((h) => h.isCompletedOn(dateStr)).length;
                      final totalCount = habitsState.activeHabits.length;
                      final isAllDone = totalCount > 0 && completedCount == totalCount;
                      final isPartial = completedCount > 0 && completedCount < totalCount;

                      return GestureDetector(
                        onTap: () => notifier.setSelectedDate(date),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black
                                : (isAllDone
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : (isPartial ? Colors.amber.withValues(alpha: 0.2) : Colors.transparent)),
                            border: Border.all(
                              color: isSelected
                                  ? SankalpTheme.brandYellow
                                  : (isToday ? SankalpTheme.brandYellow : Colors.transparent),
                              width: isSelected || isToday ? 2.0 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontWeight: isToday || isSelected ? FontWeight.w900 : FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? SankalpTheme.brandYellow
                                        : (isFuture ? Colors.grey[400] : null),
                                  ),
                                ),
                                if (!isFuture && completedCount > 0) ...[
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? SankalpTheme.brandYellow
                                          : (isAllDone ? Colors.green : Colors.orange),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Selected Date Habits Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habits for ${_formatDateHeader(selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${notifier.getCompletedCountForDate(selectedDate)} of ${habitsState.activeHabits.length} habits completed',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (selectedDate.year == DateTime.now().year &&
                    selectedDate.month == DateTime.now().month &&
                    selectedDate.day == DateTime.now().day)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (habitsState.activeHabits.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No habits created yet. Tap "Add Habit" to begin.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...habitsState.activeHabits.map((habit) {
                final isCompletedOnDay = habit.isCompletedOn(selectedDateStr);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: GestureDetector(
                      onTap: () => notifier.toggleHabitCompletion(habit.id, selectedDate),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompletedOnDay ? SankalpTheme.brandYellow : Colors.transparent,
                          border: Border.all(
                            color: isCompletedOnDay ? SankalpTheme.brandYellow : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isCompletedOnDay
                            ? const Icon(Icons.check_rounded, size: 18, color: Colors.black)
                            : null,
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: isCompletedOnDay ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${habit.category.displayName} • ${habit.currentStreak} Day Streak • +${habit.xpReward} XP',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: Text(
                      habit.timeOfDay.emoji,
                      style: const TextStyle(fontSize: 18),
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

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2C))),
      ],
    );
  }

  String _formatDateHeader(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
