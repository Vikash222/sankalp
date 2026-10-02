import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../domain/entities/habit_model.dart';
import '../providers/habits_notifier.dart';

/// Screen allowing practitioners to build, schedule, and execute daily routines
/// (Morning Monk Routine, Evening Wind-Down, Deep Work Setup) with step checklists and notifications.
class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  ConsumerState<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  void _showCreateRoutineModal([RoutineModel? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    TimeOfDay selectedTime = existing != null
        ? _parseTime(existing.time)
        : const TimeOfDay(hour: 6, minute: 30);
    List<int> selectedDays = List<int>.from(existing?.daysOfWeek ?? [1, 2, 3, 4, 5, 6, 7]);
    bool notifEnabled = existing?.isNotificationEnabled ?? true;

    final steps = existing != null
        ? existing.steps.map((s) => {'title': s.title, 'minutes': s.durationMinutes}).toList()
        : [
            {'title': 'Hydrate with 500ml water', 'minutes': 2},
            {'title': '15 mins outdoor sunlight & breathwork', 'minutes': 15},
            {'title': 'Cold water immersion / shower', 'minutes': 5},
          ];

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
                  Text(
                    existing != null ? 'Edit Protocol / Routine' : 'Create New Routine',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Routine Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Routine Name',
                      hintText: 'e.g. Morning Monk Protocol',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Time Picker Row
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alarm_rounded, color: Color(0xFF946A00)),
                    title: const Text('Scheduled Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: selectedTime);
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: const Text('Change Time'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Notification Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF946A00)),
                    title: const Text('Schedule Reminder Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Receive a push alert when routine begins', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: notifEnabled,
                    activeThumbColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setModalState(() => notifEnabled = val),
                  ),
                  const Divider(height: 20),

                  // Steps Builder Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Protocol Steps',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            steps.add({'title': 'New Step', 'minutes': 5});
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Step'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Steps List
                  ...steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: SankalpTheme.brandYellow.withValues(alpha: 0.3),
                            child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: step['title'] as String,
                              decoration: InputDecoration(
                                hintText: 'Step description',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (val) => step['title'] = val,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: '${step['minutes']}',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixText: 'm',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (val) => step['minutes'] = int.tryParse(val) ?? 5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              if (steps.length > 1) {
                                setModalState(() => steps.removeAt(idx));
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Save Routine Button
                  ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;

                      final routineSteps = steps.map((s) {
                        return RoutineStep(
                          title: s['title'] as String,
                          durationMinutes: s['minutes'] as int,
                        );
                      }).toList();

                      final notifier = ref.read(habitsNotifierProvider.notifier);
                      final timeStr = selectedTime.format(context);

                      if (existing != null) {
                        notifier.editRoutine(
                          id: existing.id,
                          title: title,
                          time: timeStr,
                          daysOfWeek: selectedDays,
                          steps: routineSteps,
                          isNotificationEnabled: notifEnabled,
                        );
                      } else {
                        notifier.addRoutine(
                          title: title,
                          time: timeStr,
                          daysOfWeek: selectedDays,
                          steps: routineSteps,
                          isNotificationEnabled: notifEnabled,
                        );
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            notifEnabled
                                ? 'Routine "$title" saved. Scheduled notification alert set for $timeStr.'
                                : 'Routine "$title" saved successfully.',
                          ),
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
                    child: const Text('Save Routine Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && h < 12) h += 12;
      if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return const TimeOfDay(hour: 6, minute: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitsNotifierProvider);
    final notifier = ref.read(habitsNotifierProvider.notifier);

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Daily Protocols & Routines',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Explanation Card
            Container(
              padding: const EdgeInsets.all(18),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: SankalpTheme.brandYellow, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unbreakable Daily Routines',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Stack habits into structured morning & evening flows. Complete routines to claim +100 bonus XP.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Routines List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Active Protocols',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRoutineModal(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Routine', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: SankalpTheme.brandYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (habitsState.routines.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No routines created. Tap "New Routine" to design your flow.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...habitsState.routines.map((routine) {
                final isCompletedToday = routine.isCompletedToday();
                final completedSteps = routine.completedStepsCount;
                final totalSteps = routine.steps.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Routine Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        routine.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      if (routine.isNotificationEnabled)
                                        const Icon(Icons.notifications_active_rounded, size: 16, color: Color(0xFF946A00)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${routine.time} • ${routine.totalMinutes} Mins total • +${routine.xpBonus} XP',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showCreateRoutineModal(routine);
                                } else if (val == 'delete') {
                                  notifier.deleteRoutine(routine.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit Protocol')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete Protocol', style: TextStyle(color: Colors.redAccent))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalSteps > 0 ? completedSteps / totalSteps : 0.0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation(SankalpTheme.brandYellow),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Steps Checkbox List
                        ...routine.steps.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final step = entry.value;

                          return InkWell(
                            onTap: () => notifier.toggleRoutineStep(routine.id, idx),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: step.isCompleted ? SankalpTheme.brandYellow : Colors.transparent,
                                      border: Border.all(
                                        color: step.isCompleted ? SankalpTheme.brandYellow : Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: step.isCompleted
                                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      step.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                                        color: step.isCompleted ? Colors.grey : null,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${step.durationMinutes}m',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Routine Completion Button
                        if (isCompletedToday)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Completed for Today! (+100 XP awarded)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                                ),
                              ],
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () {
                              notifier.completeRoutine(routine.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.bolt_rounded, color: SankalpTheme.brandYellow),
                                      const SizedBox(width: 8),
                                      Text('+${routine.xpBonus} XP! Routine "${routine.title}" completed!'),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.done_all_rounded, size: 18),
                            label: const Text('Complete Protocol for Today'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF946A00),
                              side: const BorderSide(color: Color(0xFF946A00)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size.fromHeight(40),
                            ),
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
}
