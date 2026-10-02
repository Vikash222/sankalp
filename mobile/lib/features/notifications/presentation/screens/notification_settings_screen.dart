import 'package:flutter/material.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _morningMotivation = true;
  bool _habitCheckins = true;
  bool _detoxPrompts = true;
  bool _eveningReflections = true;
  double _frequencyCap = 3.0;
  String _selectedLanguage = 'en'; // 'en' or 'hi'
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 6, minute: 30);

  final List<Map<String, String>> _sampleMessages = const [
    {
      'title': 'Morning Sunlight & Awakening',
      'body_en': 'The sun is up, Aryan. Step outside for 10 minutes of natural light to lock in your circadian rhythm.',
      'body_hi': 'सुप्रभात! 10 मिनट प्राकृतिक धूप लें और अपने दिन की अनुशासित शुरुआत करें।',
      'category': 'Morning Motivation',
    },
    {
      'title': 'Midday Habit Check-In',
      'body_en': 'Consistency is quiet, unglamorous execution. Have you completed your hydration and reading today?',
      'body_hi': 'अनुशासन ही सफलता की कुंजी है। क्या आपने आज का जल और अध्ययन लक्ष्य पूरा किया?',
      'category': 'Habit Reminder',
    },
    {
      'title': 'Digital Detox Sentinel',
      'body_en': 'You have used 1h 45m of screen time today. 15m remaining before social media lockdown.',
      'body_hi': 'आज का स्क्रीन समय समाप्त होने वाला है। फ़ोन रखकर वास्तविक जीवन पर ध्यान दें।',
      'category': 'Detox Prompt',
    },
    {
      'title': 'Evening Wind-Down & Reflection',
      'body_en': 'No screens before sleep. Journal today\'s discipline score and prepare tomorrow\'s priorities.',
      'body_hi': 'सोने से पहले स्क्रीन बंद करें। आज का आत्म-परीक्षण करें और कल के लिए तैयार हों।',
      'category': 'Night Reflection',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Notification Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quiet Hours Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bedtime_rounded, color: Color(0xFF946A00), size: 20),
                      SizedBox(width: 8),
                      Text('QUIET HOURS (SLEEP MODE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No notifications will ever disturb you during scheduled sleep hours.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimePickerButton('Sleep Time', _quietStart, (time) => setState(() => _quietStart = time)),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                      _buildTimePickerButton('Wake Time', _quietEnd, (time) => setState(() => _quietEnd = time)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Frequency Cap Slider Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DAILY FREQUENCY CAP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.grey)),
                      Text('${_frequencyCap.toInt()} per day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF946A00))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _frequencyCap,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    activeColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setState(() => _frequencyCap = val),
                  ),
                  const Text('Guarantees strict notification discipline without cluttering your phone.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bilingual Voice Language Selector
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOTIFICATION LANGUAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('English (Formal)')),
                          selected: _selectedLanguage == 'en',
                          selectedColor: SankalpTheme.brandYellow,
                          onSelected: (val) {
                            if (val) setState(() => _selectedLanguage = 'en');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('हिंदी (Hindi)')),
                          selected: _selectedLanguage == 'hi',
                          selectedColor: SankalpTheme.brandYellow,
                          onSelected: (val) {
                            if (val) setState(() => _selectedLanguage = 'hi');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification Categories Toggles
            const Text('Discipline Notification Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Morning Sunlight & Motivation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Gentle circadian light prompt around 6:30 AM', style: TextStyle(fontSize: 12)),
                    value: _morningMotivation,
                    activeThumbColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setState(() => _morningMotivation = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Habit Check-Ins & Streaks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Midday nudges to maintain daily challenge streak', style: TextStyle(fontSize: 12)),
                    value: _habitCheckins,
                    activeThumbColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setState(() => _habitCheckins = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Digital Detox & Screen Time Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Proactive alerts before approaching daily app limit', style: TextStyle(fontSize: 12)),
                    value: _detoxPrompts,
                    activeThumbColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setState(() => _detoxPrompts = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Night Wind-Down Reflection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Evening screen shutdown prompt and reflection reminder', style: TextStyle(fontSize: 12)),
                    value: _eveningReflections,
                    activeThumbColor: SankalpTheme.brandYellow,
                    onChanged: (val) => setState(() => _eveningReflections = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Notification Previews
            const Text('Sample Prompt Previews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ..._sampleMessages.map((msg) {
              final body = _selectedLanguage == 'hi' ? msg['body_hi']! : msg['body_en']!;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SankalpRoundLogo(size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(msg['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(msg['category']!, style: const TextStyle(fontSize: 10, color: Color(0xFF946A00), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(body, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.35)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerButton(String label, TimeOfDay time, Function(TimeOfDay) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
