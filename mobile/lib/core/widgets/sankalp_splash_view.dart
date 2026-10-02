import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../theme/sankalp_theme.dart';
import '../theme/theme_notifier.dart';
import 'sankalp_round_logo.dart';

/// App Startup Screen displaying the prominent circular Sankalp logo with smooth fade-in.
class SankalpSplashView extends ConsumerStatefulWidget {
  final VoidCallback? onInitialized;

  const SankalpSplashView({
    super.key,
    this.onInitialized,
  });

  @override
  ConsumerState<SankalpSplashView> createState() => _SankalpSplashViewState();
}

class _SankalpSplashViewState extends ConsumerState<SankalpSplashView> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    if (widget.onInitialized != null) {
      widget.onInitialized!();
      return;
    }

    final storage = ref.read(tokenStorageProvider);
    final authState = ref.read(authNotifierProvider);

    // If not authenticated, silently login as guest
    if (!authState.isAuthenticated) {
      try {
        await ref.read(authNotifierProvider.notifier).loginAsGuest();
      } catch (_) {
        // Fallback for offline mode
      }
    }

    if (!mounted) return;

    if (storage.hasCompletedQuiz()) {
      context.go('/app/today');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular startup logo
            const SankalpRoundLogo(
              size: 140,
              showBorder: true,
              heroTag: 'sankalp_startup_logo',
            ),
            const SizedBox(height: 28),
            const Text(
              'Sankalp',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Master Your Habits. Transform Your Life.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(SankalpTheme.brandYellow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
