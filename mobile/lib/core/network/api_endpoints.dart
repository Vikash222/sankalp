class ApiEndpoints {
  // Production live Render API endpoint
  static const String defaultBaseUrl = 'https://sankalp-api-bs21.onrender.com/api/v1';

  // Auth
  static const String guestAuth = '/auth/guest';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String upgrade = '/auth/upgrade';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // User & Profile
  static const String profile = '/user/profile';
  static const String notificationSettings = '/user/notifications/settings';

  // Device Telemetry
  static const String registerDevice = '/devices/register';

  // Diagnostic Quiz & Roadmap
  static const String quizQuestions = '/quiz/questions';
  static const String submitQuiz = '/quiz/submit';
  static const String currentRoadmap = '/roadmap/current';

  // Challenges
  static const String challengeTemplates = '/challenges/templates';
  static const String startChallenge = '/challenges/start';
  static const String activeChallenge = '/challenges/active';
  static const String todayTasks = '/challenges/today';
  static String toggleTask(int taskId) => '/challenges/tasks/$taskId/toggle';

  // Habits
  static const String habits = '/habits';
  static String habitCheckIn(int id) => '/habits/$id/checkin';
  static String habitHeatmap(int id) => '/habits/$id/heatmap';

  // Streaks
  static const String streakSummary = '/streaks/summary';
  static const String useStreakFreeze = '/streaks/freeze/use';

  // GPS Activities
  static const String activities = '/activities';
  static const String activityStats = '/activities/stats';
  static const String activityRecords = '/activities/records';
  static String activityGpx(int id) => '/activities/$id/gpx';

  // Detox & Focus
  static const String focusSessions = '/focus/sessions';
  static const String blockerRules = '/blocker/rules';
  static const String syncUsageStats = '/usage-stats/sync';
  static const String usageSummary = '/usage-stats/summary';

  // Gamification
  static const String gamificationProfile = '/gamification/profile';
  static const String badges = '/gamification/badges';
  static const String leaderboard = '/gamification/leaderboard';

  // AI Mentorship
  static const String aiChat = '/ai/chat';
  static const String aiConversations = '/ai/conversations';
}
