import 'package:flutter/material.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content':
          'Greetings, Practitioner. I am your Sankalp Discipline Coach. How can I assist you in overcoming resistance and executing your goals today?',
    },
  ];

  final List<String> _quickPrompts = [
    'I feel like procrastinating right now',
    'How do I overcome late-night doomscrolling?',
    'I missed yesterday\'s run, how do I reset?',
    'What is dopamine detox and how does it work?',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text.trim()});
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Deterministic stoic guidance simulation
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      String reply;
      final query = text.toLowerCase();
      if (query.contains('procrastinat') || query.contains('lazy') || query.contains('delay')) {
        reply =
            'Action precedes motivation. Do not wait until you feel ready; taking a 2-minute physical step immediately collapses hesitation. Stand up, drink a glass of cold water, and begin with your single smallest scheduled task.';
      } else if (query.contains('scroll') || query.contains('phone') || query.contains('screen')) {
        reply =
            'Dopamine receptors reset rapidly once visual hyper-stimulation is withheld. Place your device in another room for 30 minutes. Replace passive consumption with active physical movement or deliberate breathwork.';
      } else if (query.contains('miss') || query.contains('fail') || query.contains('streak')) {
        reply =
            'A streak is a reflection of commitment, not your identity. Never compound a mistake with guilt or despair. Return to the arena immediately today. Consistency is earned one repetition at a time.';
      } else {
        reply =
            'True discipline is freedom. Keep your vision vivid, eliminate unessential friction, and focus solely on executing the task scheduled for this hour.';
      }

      setState(() {
        _isTyping = false;
        _messages.add({'role': 'assistant', 'content': reply});
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Discipline Coach',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Prompt suggestion chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: SankalpTheme.brandYellow.withValues(alpha: 0.15),
                  side: BorderSide(color: SankalpTheme.brandYellow.withValues(alpha: 0.4)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? SankalpTheme.brandYellow
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: Border.all(
                        color: isUser
                            ? Colors.transparent
                            : Theme.of(context).dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.35,
                        color: isUser ? Colors.black : null,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: SankalpTheme.brandYellow),
                  ),
                  const SizedBox(width: 8),
                  Text('Coach is thinking...', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),

          // Input field bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask for guidance or habit strategy...',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: SankalpTheme.brandYellow),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
