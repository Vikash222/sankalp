<?php

namespace App\Services;

use App\Models\Habit;
use App\Models\HabitLog;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class HabitService
{
    public function __construct(
        protected StreakService $streakService,
        protected GamificationService $gamificationService,
    ) {}

    /**
     * Record a daily habit completion check-in.
     */
    public function checkIn(
        User $user,
        Habit $habit,
        ?string $date = null,
        ?string $notes = null,
        ?int $numericValue = null
    ): array {
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $logDate = $date ?? Carbon::now($timezone)->toDateString();

        return DB::transaction(function () use ($user, $habit, $logDate, $notes, $numericValue, $timezone) {
            // 1. Create or update HabitLog idempotently
            $existing = HabitLog::where('habit_id', $habit->id)
                ->whereDate('log_date', $logDate)
                ->first();

            if ($existing) {
                $existing->update([
                    'user_id' => $user->id,
                    'is_completed' => true,
                    'logged_value' => $numericValue ?? $habit->target_value,
                    'note' => $notes ?? $existing->note,
                    'completed_at' => now(),
                ]);
                $habitLog = $existing;
            } else {
                $habitLog = HabitLog::create([
                    'habit_id' => $habit->id,
                    'log_date' => $logDate,
                    'user_id' => $user->id,
                    'is_completed' => true,
                    'logged_value' => $numericValue ?? $habit->target_value,
                    'note' => $notes,
                    'completed_at' => now(),
                ]);
            }

            // 2. Advance Habit Streak
            $habitStreak = $this->streakService->recordDailyCompletion(
                user: $user,
                scope: 'habit',
                scopeId: $habit->id,
                completionDate: $logDate,
                userTimezone: $timezone
            );

            // 3. Advance Overall App Streak
            $overallStreak = $this->streakService->recordDailyCompletion(
                user: $user,
                scope: 'overall',
                scopeId: null,
                completionDate: $logDate,
                userTimezone: $timezone
            );

            // 4. Award XP for daily discipline
            $gamificationResult = $this->gamificationService->awardXp(
                user: $user,
                amount: 20,
                reason: 'Completed habit: ' . $habit->title,
                referenceType: 'habit_log',
                referenceId: $habitLog->id
            );

            // 5. Evaluate milestone badges
            $totalLogsCount = HabitLog::where('user_id', $user->id)->where('is_completed', true)->count();
            if ($totalLogsCount === 1) {
                $b = $this->gamificationService->unlockBadge($user, 'first_habit_completed');
                if ($b) $gamificationResult['newly_unlocked_badges'][] = $b;
            }

            if ($overallStreak->current_streak >= 7) {
                $b = $this->gamificationService->unlockBadge($user, 'streak_7');
                if ($b) $gamificationResult['newly_unlocked_badges'][] = $b;
            }
            if ($overallStreak->current_streak >= 21) {
                $b = $this->gamificationService->unlockBadge($user, 'streak_21');
                if ($b) $gamificationResult['newly_unlocked_badges'][] = $b;
            }
            if ($overallStreak->current_streak >= 90) {
                $b = $this->gamificationService->unlockBadge($user, 'streak_90');
                if ($b) $gamificationResult['newly_unlocked_badges'][] = $b;
            }

            return [
                'habit_log' => $habitLog,
                'habit_streak' => $habitStreak,
                'overall_streak' => $overallStreak,
                'gamification' => $gamificationResult,
            ];
        });
    }

    /**
     * Retrieve 365-day check-in heatmap matrix for a given habit.
     */
    public function getHeatmap(Habit $habit, ?int $year = null): array
    {
        $targetYear = $year ?? (int) date('Y');
        $startDate = Carbon::createFromDate($targetYear, 1, 1)->startOfDay();
        $endDate = Carbon::createFromDate($targetYear, 12, 31)->endOfDay();

        $logs = HabitLog::where('habit_id', $habit->id)
            ->whereBetween('log_date', [$startDate->toDateString(), $endDate->toDateString()])
            ->get(['log_date', 'is_completed', 'logged_value']);

        $heatmapMap = [];
        foreach ($logs as $log) {
            $dateStr = $log->log_date ? $log->log_date->toDateString() : (string) $log->log_date;
            $heatmapMap[$dateStr] = [
                'date' => $dateStr,
                'is_completed' => (bool) $log->is_completed,
                'value' => $log->logged_value,
            ];
        }

        return [
            'year' => $targetYear,
            'total_checkins' => count($heatmapMap),
            'records' => $heatmapMap,
        ];
    }
}
