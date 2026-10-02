import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../providers/detox_notifier.dart';

class DigitalDetoxScreen extends ConsumerStatefulWidget {
  const DigitalDetoxScreen({super.key});

  @override
  ConsumerState<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends ConsumerState<DigitalDetoxScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(detoxNotifierProvider.notifier).checkPermissions();
    }
  }

  void _showPermissionDisclosureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Color(0xFF946A00)),
            SizedBox(width: 10),
            Text('App Blocker Disclosure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'English Disclosure:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'Sankalp requires Usage Access to identify when distracting applications (such as Instagram or YouTube) are launched during active Deep Work sessions. This enables Sankalp to redirect you back to your focused activity. Your app usage data is strictly processed locally on your device and is never transmitted or sold.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Text(
                'हिंदी प्रकटीकरण:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'संकल्प को उपयोग डेटा (Usage Access) अनुमति की आवश्यकता होती है ताकि डीप वर्क सत्रों के दौरान भटकाने वाले ऐप्स खुलने पर आपको वापस ध्यान केंद्रित रखने में सहायता मिल सके। आपका उपयोग डेटा पूरी तरह आपके फ़ोन पर सुरक्षित रहता है और कहीं साझा नहीं किया जाता।',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(detoxNotifierProvider.notifier).requestUsagePermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SankalpTheme.brandYellow,
              foregroundColor: SankalpTheme.brandBlack,
            ),
            child: const Text('Enable in Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detoxState = ref.watch(detoxNotifierProvider);
    final notifier = ref.read(detoxNotifierProvider.notifier);

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Focus & Detox',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Usage Permission Disclosure Notice
            if (!detoxState.hasUsagePermission)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Usage Access Required',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enable Usage Access to allow Sankalp to enforce distraction blocking during active focus sessions.',
                      style: TextStyle(fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _showPermissionDisclosureDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange[800],
                        side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Review Disclosure & Enable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Screen Time Budget Card
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAILY SCREEN TIME BUDGET',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '45m Remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1h 15m / 2h 00m',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 75 / 120,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(SankalpTheme.brandYellow),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deep Work Focus Timer Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'DEEP WORK FOCUS TIMER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration selector chips (disabled when running)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [15, 25, 45, 90].map((mins) {
                      final isSelected = detoxState.selectedDurationMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('${mins}m'),
                          selected: isSelected,
                          onSelected: detoxState.isRunning
                              ? null
                              : (sel) {
                                  if (sel) notifier.setDuration(mins);
                                },
                          selectedColor: SankalpTheme.brandYellow,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Big Circular Countdown Display
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: CircularProgressIndicator(
                          value: detoxState.progressRatio,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(SankalpTheme.brandYellow),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            detoxState.formattedTimeRemaining,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detoxState.isRunning ? 'Active Focus' : 'Ready',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: detoxState.isRunning ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Blocked attempts indicator badge
                  if (detoxState.blockedAttemptsCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${detoxState.blockedAttemptsCount} Distractions Blocked',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),

                  // DND Toggle Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.do_not_disturb_on_rounded, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Silence Notifications (DND)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Switch(
                        value: detoxState.enableDnd,
                        activeThumbColor: SankalpTheme.brandYellow,
                        onChanged: detoxState.isRunning
                            ? null
                            : (val) {
                                if (!detoxState.hasDndPermission) {
                                  notifier.requestDndPermission();
                                } else {
                                  notifier.toggleDnd(val);
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Start / Stop Button
                  ElevatedButton(
                    onPressed: detoxState.isRunning
                        ? () => notifier.stopSessionEarly()
                        : () {
                            if (!detoxState.hasUsagePermission) {
                              _showPermissionDisclosureDialog();
                            } else {
                              notifier.startSession();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: detoxState.isRunning ? Colors.redAccent : Colors.black,
                      foregroundColor: detoxState.isRunning ? Colors.white : const Color(0xFFFFC727),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        detoxState.isRunning ? 'End Focus Session Early' : 'Begin Deep Work Session',
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Distraction Blocker List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Blocker Rules',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Apps blocked during active sessions',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showAddAppDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF946A00)),
                  label: const Text('Add App', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF946A00))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...detoxState.blockedApps.map((app) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: app.isBlocked
                          ? SankalpTheme.brandYellow.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      color: app.isBlocked ? const Color(0xFF946A00) : Colors.grey,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    app.appName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${app.dailyLimit} • ${app.packageName}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: app.isBlocked,
                        activeThumbColor: SankalpTheme.brandYellow,
                        onChanged: (val) => notifier.toggleAppBlock(app.packageName),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                        tooltip: 'Remove',
                        onPressed: () {
                          notifier.removeBlockedApp(app.packageName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${app.appName} removed from blocklist.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddAppDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddAppModalSheet(
        onAddApp: (name, pkg) {
          ref.read(detoxNotifierProvider.notifier).addCustomBlockedApp(name, pkg);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name added to focus blocklist.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class _AddAppModalSheet extends ConsumerStatefulWidget {
  final void Function(String name, String packageName) onAddApp;

  const _AddAppModalSheet({required this.onAddApp});

  @override
  ConsumerState<_AddAppModalSheet> createState() => _AddAppModalSheetState();
}

class _AddAppModalSheetState extends ConsumerState<_AddAppModalSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _customPkgCtrl = TextEditingController();

  List<Map<String, dynamic>> _installedApps = [];
  bool _isLoadingApps = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstalledApps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _customNameCtrl.dispose();
    _customPkgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInstalledApps() async {
    try {
      final notifier = ref.read(detoxNotifierProvider.notifier);
      final apps = await notifier.getInstalledUserApps();
      if (!mounted) return;
      setState(() {
        _installedApps = apps;
        _isLoadingApps = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingApps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedList = ref.watch(detoxNotifierProvider).blockedApps;
    final blockedPackageSet = blockedList.map((a) => a.packageName).toSet();

    final filteredInstalled = _installedApps.where((app) {
      final name = (app['app_name'] as String? ?? '').toLowerCase();
      final pkg = (app['package_name'] as String? ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || pkg.contains(q);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add App to Blocklist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: SankalpTheme.brandYellow,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Installed Apps (फोन के ऐप्स)'),
              Tab(text: 'Custom Package (कस्टम)'),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Installed Apps
                Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search installed applications...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _isLoadingApps
                          ? const Center(child: CircularProgressIndicator())
                          : filteredInstalled.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      const Text('No matching applications found.', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredInstalled.length,
                                  itemBuilder: (ctx, idx) {
                                    final app = filteredInstalled[idx];
                                    final appName = app['app_name'] as String? ?? 'App';
                                    final pkg = app['package_name'] as String? ?? '';
                                    final alreadyAdded = blockedPackageSet.contains(pkg);

                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                                      leading: CircleAvatar(
                                        backgroundColor: SankalpTheme.brandYellow.withValues(alpha: 0.2),
                                        child: Text(
                                          appName.isNotEmpty ? appName[0].toUpperCase() : 'A',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF946A00)),
                                        ),
                                      ),
                                      title: Text(appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      subtitle: Text(pkg, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      trailing: ElevatedButton(
                                        onPressed: alreadyAdded
                                            ? null
                                            : () {
                                                widget.onAddApp(appName, pkg);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: alreadyAdded ? Colors.grey[300] : SankalpTheme.brandYellow,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          minimumSize: const Size(0, 32),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          alreadyAdded ? 'Added' : '+ Add',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),

                // Tab 2: Custom Package Name
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter custom application details:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'App Display Name',
                          hintText: 'e.g. BGMI, Prime Video',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customPkgCtrl,
                        decoration: InputDecoration(
                          labelText: 'Package Name',
                          hintText: 'e.g. com.pubg.imobile',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Popular presets:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            label: const Text('+ WhatsApp', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'WhatsApp';
                              _customPkgCtrl.text = 'com.whatsapp';
                            },
                          ),
                          ActionChip(
                            label: const Text('+ Snapchat', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'Snapchat';
                              _customPkgCtrl.text = 'com.snapchat.android';
                            },
                          ),
                          ActionChip(
                            label: const Text('+ Netflix', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'Netflix';
                              _customPkgCtrl.text = 'com.netflix.mediaclient';
                            },
                          ),
                          ActionChip(
                            label: const Text('+ Prime Video', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'Prime Video';
                              _customPkgCtrl.text = 'com.amazon.avod.thirdpartyclient';
                            },
                          ),
                          ActionChip(
                            label: const Text('+ Telegram', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'Telegram';
                              _customPkgCtrl.text = 'org.telegram.messenger';
                            },
                          ),
                          ActionChip(
                            label: const Text('+ BGMI', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              _customNameCtrl.text = 'Battlegrounds Mobile India';
                              _customPkgCtrl.text = 'com.pubg.imobile';
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final name = _customNameCtrl.text.trim();
                          final pkg = _customPkgCtrl.text.trim();
                          if (name.isNotEmpty && pkg.isNotEmpty) {
                            widget.onAddApp(name, pkg);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SankalpTheme.brandYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add to Blocklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
