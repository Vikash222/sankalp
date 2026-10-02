import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/sankalp_theme.dart';
import '../../../../core/widgets/sankalp_round_logo.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/friends_league_notifier.dart';
import '../providers/gamification_notifier.dart';

class LeaderboardUser {
  final int rank;
  final String name;
  final String city;
  final int xp;
  final int streakDays;
  final bool isGpsVerified;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.city,
    required this.xp,
    required this.streakDays,
    this.isGpsVerified = true,
    this.isCurrentUser = false,
  });
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedTab = 0; // 0: Global, 1: City, 2: Friends

  final List<LeaderboardUser> _globalUsers = const [
    LeaderboardUser(rank: 1, name: 'Vikramaditya S.', city: 'New Delhi', xp: 4250, streakDays: 48, isGpsVerified: true),
    LeaderboardUser(rank: 2, name: 'Ananya Sharma', city: 'Bengaluru', xp: 3980, streakDays: 42, isGpsVerified: true),
    LeaderboardUser(rank: 3, name: 'Rohan Mehta', city: 'Mumbai', xp: 3740, streakDays: 35, isGpsVerified: true),
    LeaderboardUser(rank: 4, name: 'Siddharth Rao', city: 'Hyderabad', xp: 3410, streakDays: 28, isGpsVerified: true),
    LeaderboardUser(rank: 5, name: 'Pooja Nair', city: 'Pune', xp: 3120, streakDays: 24, isGpsVerified: true),
    LeaderboardUser(rank: 6, name: 'Kabir Patel', city: 'Ahmedabad', xp: 2950, streakDays: 21, isGpsVerified: true),
    LeaderboardUser(rank: 7, name: 'Neha Gupta', city: 'Jaipur', xp: 2600, streakDays: 16, isGpsVerified: true),
    LeaderboardUser(rank: 8, name: 'Aditya Sen', city: 'Kolkata', xp: 2480, streakDays: 14, isGpsVerified: true),
    LeaderboardUser(rank: 9, name: 'Devendra K.', city: 'Chandigarh', xp: 2310, streakDays: 12, isGpsVerified: true),
  ];

  final List<LeaderboardUser> _cityUsers = const [
    LeaderboardUser(rank: 1, name: 'Vikramaditya S.', city: 'Connaught Place', xp: 4250, streakDays: 48, isGpsVerified: true),
    LeaderboardUser(rank: 2, name: 'Aarav Verma', city: 'Saket', xp: 3310, streakDays: 26, isGpsVerified: true),
    LeaderboardUser(rank: 3, name: 'Meera Chawla', city: 'Dwarka', xp: 2920, streakDays: 22, isGpsVerified: true),
    LeaderboardUser(rank: 4, name: 'Kunal Joshi', city: 'Rohini', xp: 2640, streakDays: 18, isGpsVerified: true),
    LeaderboardUser(rank: 5, name: 'Simran Kaur', city: 'Hauz Khas', xp: 2410, streakDays: 15, isGpsVerified: true),
  ];

  void _showRedeemDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: Color(0xFF946A00)),
            SizedBox(width: 8),
            Text('Redeem Invite Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a friend\'s referral code to instantly claim +250 Bonus XP and add them to your Friends League.',
              style: TextStyle(fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Referral Code',
                hintText: 'e.g. SANKALP-2H7K',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.trim();
              if (code.isNotEmpty) {
                final success = await ref.read(friendsLeagueNotifierProvider.notifier).redeemReferralCode(code);
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: SankalpTheme.brandYellow),
                          SizedBox(width: 8),
                          Text('Code redeemed! +250 Bonus XP granted and friend added!'),
                        ],
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid referral code or already redeemed.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SankalpTheme.brandYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Redeem (+250 XP)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Friend to League', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Friend Name',
                hintText: 'e.g. Rahul',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Friend Code / Invite Code',
                hintText: 'e.g. SANKALP-8M1P',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim();
              if (name.isNotEmpty && code.isNotEmpty) {
                ref.read(friendsLeagueNotifierProvider.notifier).addFriendManually(
                      name: name,
                      referralCode: code,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name added to your Friends League!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SankalpTheme.brandYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Add Friend', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationNotifierProvider);
    final friendsState = ref.watch(friendsLeagueNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final userName = user?.name ?? 'Practitioner';

    // Build current list of users based on tab
    List<LeaderboardUser> currentUsers;
    if (_selectedTab == 0) {
      currentUsers = _globalUsers;
    } else if (_selectedTab == 1) {
      currentUsers = _cityUsers;
    } else {
      // Tab 2: Friends League
      final sortedFriends = ref.read(friendsLeagueNotifierProvider.notifier).getSortedFriends(
            gamification.totalXp,
            userName,
          );
      currentUsers = sortedFriends.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final f = entry.value;
        return LeaderboardUser(
          rank: rank,
          name: f.name,
          city: f.city,
          xp: f.weeklyXp,
          streakDays: f.streakDays,
          isGpsVerified: f.isGpsVerified,
          isCurrentUser: f.isCurrentUser,
        );
      }).toList();
    }

    // Find current user rank
    int myRank = 7;
    int myXp = gamification.totalXp;
    for (int i = 0; i < currentUsers.length; i++) {
      if (currentUsers[i].isCurrentUser) {
        myRank = currentUsers[i].rank;
        myXp = currentUsers[i].xp;
        break;
      }
    }

    return Scaffold(
      appBar: const SankalpAppBar(
        title: 'Discipline League',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // League Tier & Reset Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFB8860B), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GOLD DISCIPLINE LEAGUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        Text('Top 3 promote to Diamond Tier', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Resets in 2d 14h', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Circle Scope Switcher (Global / City / Friends)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildScopeTab(0, 'Global Tier'),
                  _buildScopeTab(1, 'Delhi Circle'),
                  _buildScopeTab(2, 'Friends League'),
                ],
              ),
            ),
          ),

          // Friends Referral & Invite Banner when on Friends Tab
          if (_selectedTab == 2)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SankalpTheme.brandYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SankalpTheme.brandYellow.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR INVITE CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF946A00))),
                          const SizedBox(height: 2),
                          Text(friendsState.myReferralCode, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: friendsState.myReferralCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Referral code copied to clipboard!'), behavior: SnackBarBehavior.floating),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: () {
                              final inviteText = 'Join me on Sankalp! Use my invite code ${friendsState.myReferralCode} to get +250 Bonus XP: https://sankalp.app/join';
                              Clipboard.setData(ClipboardData(text: inviteText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invitation copied! Share with friends on WhatsApp/SMS.'), behavior: SnackBarBehavior.floating),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 14),
                            label: const Text('Share App'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: SankalpTheme.brandYellow,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showRedeemDialog,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text('Redeem Friend Code (+250 XP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _showAddFriendDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SankalpTheme.brandYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text('+ Add Friend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Podium for Top 3
          if (currentUsers.length >= 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPodiumSpot(currentUsers[1], 2, 80, const Color(0xFFC0C0C0)),
                  const SizedBox(width: 12),
                  _buildPodiumSpot(currentUsers[0], 1, 105, const Color(0xFFFFD700)),
                  const SizedBox(width: 12),
                  _buildPodiumSpot(currentUsers[2], 3, 70, const Color(0xFFCD7F32)),
                ],
              ),
            ),

          const SizedBox(height: 4),
          const Divider(height: 1),

          // Scrollable Rankings List (Ranks 4+)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: currentUsers.length > 3 ? currentUsers.length - 3 : currentUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = currentUsers.length > 3 ? currentUsers[index + 3] : currentUsers[index];
                return _buildUserTile(user);
              },
            ),
          ),
        ],
      ),

      // Sticky Current User Ranking Banner at bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: SankalpTheme.brandYellow,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('#$myRank', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$userName (You)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    myRank <= 3 ? '🏆 Promotion Zone (Diamond League)' : 'Safe from Demotion Zone • Active Streak',
                    style: TextStyle(
                      fontSize: 11,
                      color: myRank <= 3 ? Colors.green[700] : Colors.grey,
                      fontWeight: myRank <= 3 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text('$myXp XP', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeTab(int idx, String title) {
    final isSel = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
        child: Container(
          decoration: BoxDecoration(
            color: isSel ? Theme.of(context).cardTheme.color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSel ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
              color: isSel ? null : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSpot(LeaderboardUser user, int rank, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspace_premium_rounded, color: color, size: rank == 1 ? 26 : 20),
        const SizedBox(height: 4),
        Text(
          user.name.split(' ').first,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text('${user.xp} XP', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          width: 72,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.9)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(LeaderboardUser user) {
    return Card(
      elevation: user.isCurrentUser ? 2 : 0,
      color: user.isCurrentUser ? SankalpTheme.brandYellow.withValues(alpha: 0.12) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: user.isCurrentUser
            ? const BorderSide(color: SankalpTheme.brandYellow, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: SizedBox(
          width: 32,
          child: Text(
            '#${user.rank}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: user.isCurrentUser ? const Color(0xFF946A00) : Colors.grey,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  fontWeight: user.isCurrentUser ? FontWeight.w900 : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (user.isGpsVerified)
              const Tooltip(
                message: 'GPS Verified Workouts',
                child: Icon(Icons.verified_rounded, size: 14, color: Color(0xFF1E88E5)),
              ),
          ],
        ),
        subtitle: Text(
          '${user.city} • 🔥 ${user.streakDays} Day Streak',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${user.xp} XP',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: user.isCurrentUser ? const Color(0xFF946A00) : null,
              ),
            ),
            if (!user.isCurrentUser && _selectedTab == 2) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.waving_hand_rounded, size: 16, color: Color(0xFF946A00)),
                tooltip: 'Cheer Practitioner',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You cheered ${user.name}! High five sent.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
