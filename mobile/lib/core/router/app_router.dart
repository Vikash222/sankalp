import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../features/challenges/presentation/screens/challenges_catalog_screen.dart';
import '../../features/detox/presentation/screens/digital_detox_screen.dart';
import '../../features/gamification/presentation/screens/badges_catalog_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../../features/gamification/presentation/screens/levels_progression_screen.dart';
import '../../features/habits/presentation/screens/habit_calendar_screen.dart';
import '../../features/habits/presentation/screens/routine_builder_screen.dart';
import '../../features/habits/presentation/screens/today_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/data/models/quiz_models.dart';
import '../../features/quiz/presentation/screens/onboarding_quiz_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/roadmap/presentation/screens/roadmap_screen.dart';
import '../widgets/sankalp_shell.dart';
import '../widgets/sankalp_splash_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Startup Screen with round logo
      GoRoute(
        path: '/',
        builder: (context, state) => const SankalpSplashView(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Diagnostic Onboarding Questionnaire
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingQuizScreen(),
      ),

      // Transformation Roadmap
      GoRoute(
        path: '/roadmap',
        builder: (context, state) {
          final result = state.extra as QuizSubmitResultModel?;
          return RoadmapScreen(initialResult: result);
        },
      ),

      // Shell Route (Persistent 4-Tab Navigation)
      ShellRoute(
        builder: (context, state, child) => SankalpShell(child: child),
        routes: [
          GoRoute(
            path: '/app/today',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
          GoRoute(
            path: '/app/challenges',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChallengesCatalogScreen(),
            ),
          ),
          GoRoute(
            path: '/app/detox',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DigitalDetoxScreen(),
            ),
          ),
          GoRoute(
            path: '/app/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Redirect legacy activity tracker paths to Today
      GoRoute(
        path: '/app/tracker',
        redirect: (context, state) => '/app/today',
      ),
      GoRoute(
        path: '/tracker/live',
        redirect: (context, state) => '/app/today',
      ),
      GoRoute(
        path: '/tracker/summary',
        redirect: (context, state) => '/app/today',
      ),
      GoRoute(
        path: '/tracker/history',
        redirect: (context, state) => '/app/today',
      ),

      // Gamification & Leagues Routes
      GoRoute(
        path: '/gamification/badges',
        builder: (context, state) => const BadgesCatalogScreen(),
      ),
      GoRoute(
        path: '/gamification/levels',
        builder: (context, state) => const LevelsProgressionScreen(),
      ),
      GoRoute(
        path: '/gamification/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Settings & Notifications
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Habits Calendar & Routine Routes
      GoRoute(
        path: '/habits/calendar',
        builder: (context, state) => const HabitCalendarScreen(),
      ),
      GoRoute(
        path: '/habits/routines',
        builder: (context, state) => const RoutineBuilderScreen(),
      ),

      // AI Mentor Coach
      GoRoute(
        path: '/ai-coach',
        builder: (context, state) => const AiCoachScreen(),
      ),
    ],
  );
});
