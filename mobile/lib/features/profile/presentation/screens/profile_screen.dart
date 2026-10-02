import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/sync/offline_sync_engine.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../../activity_tracker/data/datasources/activity_native_bridge.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../gamification/presentation/providers/gamification_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ActivityNativeBridge _bridge = ActivityNativeBridge();
  bool _isSyncing = false;
  bool _hasNotifPerm = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notif = await _bridge.hasNotificationPermission();
    if (mounted) {
      setState(() {
        _hasNotifPerm = notif;
      });
    }
  }

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);
    try {
      final engine = ref.read(offlineSyncEngineProvider);
      final count = await engine.syncPendingMutations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Text(
                count > 0
                    ? 'Successfully synced $count queued discipline records to cloud.'
                    : 'All records are already up to date with cloud.',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offline mode active: Data stored safely on device ($e).'),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showAuthModal(BuildContext context, {bool isRegister = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AuthBottomSheet(
        initialRegister: isRegister,
        onSuccess: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.greenAccent),
                  SizedBox(width: 8),
                  Text('Authentication successful! Profile synced.'),
                ],
              ),
              backgroundColor: Colors.green[900],
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final themeState = ref.watch(themeNotifierProvider);
    final gamification = ref.watch(gamificationNotifierProvider);
    final syncEngine = ref.watch(offlineSyncEngineProvider);

    final user = authState.user;
    final isGuest = authState.isGuest;
    final pendingMutations = syncEngine.pendingCount;

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Profile & Settings',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SankalpRoundLogo(size: 60),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Sankalp Practitioner',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isGuest ? 'Anonymous Guest Session' : (user?.email ?? ''),
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isGuest
                                    ? Colors.grey.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isGuest ? 'GUEST SESSION' : 'VERIFIED ACCOUNT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isGuest ? Colors.grey : Colors.green[800],
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (isGuest) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/auth/register'),
                            icon: const Icon(Icons.person_add_rounded, size: 18),
                            label: const Text('Register Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SankalpTheme.brandYellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/auth/login'),
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAuthModal(context, isRegister: false),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: const Text('Switch Account'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isGuest) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SankalpTheme.brandYellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SankalpTheme.brandYellow.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF946A00)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Guest Session Active: Register an account to safeguard your daily habits, streaks, and GPS runs permanently.',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Cloud Data Sync & Backup Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: pendingMutations > 0
                          ? Colors.orange.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      pendingMutations > 0 ? Icons.sync_problem_rounded : Icons.cloud_done_rounded,
                      color: pendingMutations > 0 ? Colors.orange : Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingMutations > 0
                              ? '$pendingMutations Offline Records Queued'
                              : 'Cloud Synchronized',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pendingMutations > 0
                              ? 'Saved locally on phone. Tap to sync.'
                              : 'All habits & discipline records backed up.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSyncing ? null : _handleManualSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: SankalpTheme.brandYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: SankalpTheme.brandYellow),
                          )
                        : const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Level & XP Progress Card
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/gamification/levels'),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LEVEL ${gamification.level} • DISCIPLINO',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Color(0xFF946A00),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${gamification.totalXp} XP Total',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (gamification.totalXp % 500) / 500.0,
                          minHeight: 8,
                          backgroundColor: const Color(0x1F000000),
                          valueColor: const AlwaysStoppedAnimation(SankalpTheme.brandYellow),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to inspect all 50 Level perks and progression milestones.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Theme Preferences Section
            const Text(
              'App Theme Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildThemeTile(
                    context: context,
                    ref: ref,
                    mode: SankalpThemeMode.day,
                    title: 'Day Mode',
                    subtitle: 'Yellow & White',
                    isSelected: themeState.mode == SankalpThemeMode.day,
                    color: const Color(0xFFFFC727),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildThemeTile(
                    context: context,
                    ref: ref,
                    mode: SankalpThemeMode.dark,
                    title: 'Dark Mode',
                    subtitle: 'Charcoal Slate',
                    isSelected: themeState.mode == SankalpThemeMode.dark,
                    color: const Color(0xFF1E222B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildThemeTile(
                    context: context,
                    ref: ref,
                    mode: SankalpThemeMode.night,
                    title: 'Night Mode',
                    subtitle: 'AMOLED Black',
                    isSelected: themeState.mode == SankalpThemeMode.night,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildThemeTile(
                    context: context,
                    ref: ref,
                    mode: SankalpThemeMode.custom,
                    title: 'Custom Mode',
                    subtitle: 'Golden Amber',
                    isSelected: themeState.mode == SankalpThemeMode.custom,
                    color: const Color(0xFFFFB300),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Badges Catalog Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Milestone Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/gamification/badges'),
                  child: const Text('View All 30 (Unlockable)', style: TextStyle(color: Color(0xFF946A00), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildBadgeItem('First Step', Icons.check_circle_rounded, gamification.isBadgeUnlocked('first-step')),
                _buildBadgeItem('7-Day Flame', Icons.local_fire_department_rounded, gamification.isBadgeUnlocked('7-day-flame')),
                _buildBadgeItem('21-Day Finisher', Icons.verified_rounded, gamification.isBadgeUnlocked('21-day-habit-builder')),
                _buildBadgeItem('Focus Monk', Icons.self_improvement_rounded, gamification.isBadgeUnlocked('focus-master-10h')),
                _buildBadgeItem('Flow Master', Icons.alarm_on_rounded, gamification.isBadgeUnlocked('flow-master-10h')),
                _buildBadgeItem('90-Day Monk', Icons.military_tech_rounded, gamification.isBadgeUnlocked('90-day-monk')),
                _buildBadgeItem('Century Club', Icons.workspace_premium_rounded, gamification.isBadgeUnlocked('century-club')),
                _buildBadgeItem('Level 50 Master', Icons.diamond_rounded, gamification.isBadgeUnlocked('level-50-master')),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Links to Gamification, Habits & Protocols
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFB8860B), size: 22),
                ),
                title: const Text('Discipline Leagues & Friends Circle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Friends League rankings, referral invites & weekly Gold Tier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () => context.push('/gamification/leaderboard'),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.blue, size: 22),
                ),
                title: const Text('Habit Calendar & Streaks Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Monthly completion heatmap and retro check-in', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () => context.push('/habits/calendar'),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.purple, size: 22),
                ),
                title: const Text('Daily Protocols & Routines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Morning Monk Protocol & scheduled alerts', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () => context.push('/habits/routines'),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF946A00), size: 22),
                ),
                title: const Text('Discipline Push Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Quiet hours, bilingual voice, and frequency caps', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () => context.push('/settings/notifications'),
              ),
            ),
            const SizedBox(height: 24),

            // Device Permissions Section
            const Text(
              'Device Permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Notification Permission Tile
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _hasNotifPerm
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _hasNotifPerm ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                            color: _hasNotifPerm ? Colors.green : Colors.orange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Habit & Routine Notifications',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _hasNotifPerm
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _hasNotifPerm ? 'ENABLED' : 'DISABLED',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: _hasNotifPerm ? Colors.green[800] : Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Daily check-in alerts and routine schedule reminders',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (!_hasNotifPerm)
                          ElevatedButton(
                            onPressed: () async {
                              await _bridge.requestNotificationPermission();
                              await _checkPermissions();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: SankalpTheme.brandYellow,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Enable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 20),
                            onPressed: () => _bridge.openAppSettings(),
                            tooltip: 'Device Settings',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Logout Action
            OutlinedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out. Local anonymous session active.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sign Out Session', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required WidgetRef ref,
    required SankalpThemeMode mode,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        ref.read(themeNotifierProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? SankalpTheme.brandYellow : Theme.of(context).dividerColor.withValues(alpha: 0.15),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(String title, IconData icon, bool unlocked) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFFC727).withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFFC727)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            unlocked ? icon : Icons.lock_outline_rounded,
            color: unlocked ? const Color(0xFF946A00) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: unlocked ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBottomSheet extends ConsumerStatefulWidget {
  final bool initialRegister;
  final VoidCallback onSuccess;

  const _AuthBottomSheet({
    required this.initialRegister,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends ConsumerState<_AuthBottomSheet> {
  late bool _isRegister;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialRegister;
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    if (_isRegister && name.isEmpty) {
      setState(() => _error = 'Please enter your practitioner name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        await ref.read(authNotifierProvider.notifier).register(
              name: name,
              email: email,
              password: pass,
            );
      } else {
        await ref.read(authNotifierProvider.notifier).login(
              email: email,
              password: pass,
            );
      }
      widget.onSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRegister ? 'Create Sankalp Account' : 'Welcome Back Practitioner',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _isRegister
                  ? 'Preserve your streak, badges, and workouts across devices.'
                  : 'Sign in with your email to restore your cloud progress.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (_isRegister) ...[
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Practitioner Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: SankalpTheme.brandYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      _isRegister ? 'Register & Lock In' : 'Sign In Session',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () => setState(() => _isRegister = !_isRegister),
              child: Text(
                _isRegister
                    ? 'Already have an account? Sign In'
                    : 'Need a permanent account? Register Here',
                style: const TextStyle(color: Color(0xFF946A00), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
