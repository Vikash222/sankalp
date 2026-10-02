import 'package:flutter/material.dart';
import '../theme/sankalp_theme.dart';
import '../../features/activity_tracker/data/datasources/activity_native_bridge.dart';

/// Notification setup dialog shown on application startup to ensure habit and routine alerts work reliably.
class StartupPermissionSetupDialog extends StatefulWidget {
  final VoidCallback? onComplete;

  const StartupPermissionSetupDialog({super.key, this.onComplete});

  /// Evaluates whether notification permission is missing and shows dialog if needed.
  static Future<void> checkAndShow(
    BuildContext context, {
    required ActivityNativeBridge bridge,
  }) async {
    try {
      final hasNotif = await bridge.hasNotificationPermission();

      if (!context.mounted) return;

      if (!hasNotif) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => StartupPermissionSetupDialog(
            onComplete: () {},
          ),
        );
      }
    } catch (_) {}
  }

  @override
  State<StartupPermissionSetupDialog> createState() =>
      _StartupPermissionSetupDialogState();
}

class _StartupPermissionSetupDialogState
    extends State<StartupPermissionSetupDialog> {
  final ActivityNativeBridge _bridge = ActivityNativeBridge();
  bool _isRequesting = false;

  Future<void> _handleGrantPermissions() async {
    setState(() => _isRequesting = true);
    try {
      await _bridge.requestNotificationPermission();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isRequesting = false);
    Navigator.of(context).pop();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF946A00),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habit Reminders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Keep your daily streak alive • दैनिक स्ट्रीक के लिए',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Feature Item: Notifications
            _buildPermissionItem(
              icon: Icons.notifications_rounded,
              title: 'Habit & Routine Alerts',
              titleHi: 'आदतों और रूटीन के अलर्ट',
              desc:
                  'Timely morning and evening check-in reminders so you never forget your habits or break your discipline streak.',
              descHi:
                  'सुबह और शाम की आदतों की समय पर याद दिलाने के लिए ताकि आपकी स्ट्रीक कभी न टूटे।',
            ),
            const SizedBox(height: 22),

            // Grant Button
            ElevatedButton(
              onPressed: _isRequesting ? null : _handleGrantPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: SankalpTheme.brandYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Enable Notifications • अनुमति दें',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 8),

            // Later Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onComplete?.call();
              },
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String titleHi,
    required String desc,
    required String descHi,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SankalpTheme.brandYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF946A00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($titleHi)',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, height: 1.3, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
