<?php

use App\Http\Controllers\Api\v1\ActivityController;
use App\Http\Controllers\Api\v1\AiCoachController;
use App\Http\Controllers\Api\v1\AuthController;
use App\Http\Controllers\Api\v1\BlockedAppRuleController;
use App\Http\Controllers\Api\v1\ChallengeController;
use App\Http\Controllers\Api\v1\DeviceController;
use App\Http\Controllers\Api\v1\FocusSessionController;
use App\Http\Controllers\Api\v1\GamificationController;
use App\Http\Controllers\Api\v1\HabitController;
use App\Http\Controllers\Api\v1\QuizController;
use App\Http\Controllers\Api\v1\RoadmapController;
use App\Http\Controllers\Api\v1\StreakController;
use App\Http\Controllers\Api\v1\UsageStatsController;
use App\Http\Controllers\Api\v1\UserProfileController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    // -------------------------------------------------------------
    // Public Endpoints
    // -------------------------------------------------------------
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('guest', [AuthController::class, 'guest']);
    });

    Route::get('quiz/questions', [QuizController::class, 'getQuestions']);
    Route::get('challenges/templates', [ChallengeController::class, 'listTemplates']);
    Route::get('challenges/templates/{id}', [ChallengeController::class, 'getTemplate']);

    // -------------------------------------------------------------
    // Authenticated Endpoints (Sanctum)
    // -------------------------------------------------------------
    Route::middleware('auth:sanctum')->group(function () {
        // Identity & Auth Lifecycle
        Route::prefix('auth')->group(function () {
            Route::post('upgrade', [AuthController::class, 'upgrade']);
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
        });

        // User Profile & Settings
        Route::prefix('user')->group(function () {
            Route::get('profile', [UserProfileController::class, 'getProfile']);
            Route::put('profile', [UserProfileController::class, 'updateProfile']);
            Route::get('notifications/settings', [UserProfileController::class, 'getNotificationSettings']);
            Route::put('notifications/settings', [UserProfileController::class, 'updateNotificationSettings']);
        });

        // Device Telemetry
        Route::post('devices/register', [DeviceController::class, 'register']);

        // Diagnostic Quiz & Roadmaps
        Route::post('quiz/submit', [QuizController::class, 'submitQuiz']);
        Route::get('roadmap/current', [RoadmapController::class, 'getCurrent']);

        // Structured Challenges
        Route::prefix('challenges')->group(function () {
            Route::post('start', [ChallengeController::class, 'startChallenge']);
            Route::get('active', [ChallengeController::class, 'getActiveChallenge']);
            Route::get('today', [ChallengeController::class, 'getTodayTasks']);
            Route::post('tasks/{id}/toggle', [ChallengeController::class, 'toggleTask']);
        });

        // Habits Engine
        Route::prefix('habits')->group(function () {
            Route::get('/', [HabitController::class, 'index']);
            Route::post('/', [HabitController::class, 'store']);
            Route::get('{id}', [HabitController::class, 'show']);
            Route::put('{id}', [HabitController::class, 'update']);
            Route::delete('{id}', [HabitController::class, 'destroy']);
            Route::post('{id}/checkin', [HabitController::class, 'checkin']);
            Route::get('{id}/heatmap', [HabitController::class, 'heatmap']);
        });

        // Streaks & Freezes
        Route::prefix('streaks')->group(function () {
            Route::get('summary', [StreakController::class, 'getSummary']);
            Route::post('freeze/use', [StreakController::class, 'useFreeze']);
        });

        // GPS Running & Cycling Workouts (Phase 4B)
        Route::prefix('activities')->group(function () {
            Route::get('/', [ActivityController::class, 'index']);
            Route::post('/', [ActivityController::class, 'store']);
            Route::get('stats', [ActivityController::class, 'stats']);
            Route::get('records', [ActivityController::class, 'records']);
            Route::get('{id}', [ActivityController::class, 'show']);
            Route::delete('{id}', [ActivityController::class, 'destroy']);
            Route::get('{id}/gpx', [ActivityController::class, 'exportGpx']);
        });

        // Digital Detox & Deep Work
        Route::prefix('focus')->group(function () {
            Route::get('sessions', [FocusSessionController::class, 'index']);
            Route::post('sessions', [FocusSessionController::class, 'store']);
        });

        Route::prefix('blocker')->group(function () {
            Route::get('rules', [BlockedAppRuleController::class, 'index']);
            Route::post('rules', [BlockedAppRuleController::class, 'store']);
            Route::delete('rules/{id}', [BlockedAppRuleController::class, 'destroy']);
        });

        Route::prefix('usage-stats')->group(function () {
            Route::post('sync', [UsageStatsController::class, 'sync']);
            Route::get('summary', [UsageStatsController::class, 'summary']);
        });

        // Gamification & Leaderboard
        Route::prefix('gamification')->group(function () {
            Route::get('profile', [GamificationController::class, 'profile']);
            Route::get('badges', [GamificationController::class, 'badges']);
            Route::get('leaderboard', [GamificationController::class, 'leaderboard']);
        });

        // Open-Source AI Coach Mentorship
        Route::prefix('ai')->group(function () {
            Route::post('chat', [AiCoachController::class, 'chat']);
            Route::get('conversations', [AiCoachController::class, 'conversations']);
            Route::get('conversations/{id}/messages', [AiCoachController::class, 'messages']);
        });
    });
});
