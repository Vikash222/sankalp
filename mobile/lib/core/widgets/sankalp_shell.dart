import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/sankalp_theme.dart';

class SankalpShell extends StatelessWidget {
  final Widget child;

  const SankalpShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/app/today')) return 0;
    if (location.startsWith('/app/challenges')) return 1;
    if (location.startsWith('/app/detox')) return 2;
    if (location.startsWith('/app/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/app/today');
        break;
      case 1:
        context.go('/app/challenges');
        break;
      case 2:
        context.go('/app/detox');
        break;
      case 3:
        context.go('/app/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        indicatorColor: SankalpTheme.brandYellow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny_rounded, color: Colors.black),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: Colors.black),
            label: 'Challenges',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty_rounded),
            selectedIcon: Icon(Icons.hourglass_full_rounded, color: Colors.black),
            label: 'Detox',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
