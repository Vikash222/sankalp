<?php

namespace App\Services;

use App\Models\Streak;
use App\Models\StreakFreeze;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Production Timezone-Aware, Freeze-Aware Streak Calculation Engine.
 */
class StreakService
{
    public const MAX_FREEZE_INVENTORY = 2;
    public const FREEZE_EARN_INTERVAL_DAYS = 7;

    /**
     * Facade method matching recordDailyCompletion signature.
     */
    public function recordDailyCompletion(
        User $user,
        string $scope = 'overall',
        ?int $scopeId = null,
        ?string $completionDate = null,
        ?string $userTimezone = null
    ): Streak {
        $habitId = ($scope === 'habit') ? $scopeId : null;
        $result = $this->recordCheckin($user, $habitId, $completionDate);
        return $result['streak'];
    }

    /**
     * Records a habit or challenge completion check-in and updates streak status.
     *
     * @param User $user
     * @param int|null $habitId null indicates aggregate daily lifestyle/challenge streak
     * @param string|null $overrideDate optional 'Y-m-d' for offline queue replays
     * @return array [Streak $streak, bool $isStreakIncremented, bool $wasFreezeConsumed]
     */
    public function recordCheckin(User $user, ?int $habitId = null, ?string $overrideDate = null): array
    {
        return DB::transaction(function () use ($user, $habitId, $overrideDate) {
            $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
            $today = $overrideDate 
                ? Carbon::parse($overrideDate, $timezone)->startOfDay()
                : Carbon::now($timezone)->startOfDay();

            $streak = Streak::firstOrCreate(
                ['user_id' => $user->id, 'habit_id' => $habitId],
                [
                    'current_streak' => 0,
                    'longest_streak' => 0,
                    'last_completed_date' => null,
                    'freeze_count' => 0,
                ]
            );

            // 1. First check-in ever
            if ($streak->last_completed_date === null) {
                $streak->current_streak = 1;
                $streak->longest_streak = 1;
                $streak->last_completed_date = $today->toDateString();
                $streak->save();

                return [
                    'streak' => $streak,
                    'incremented' => true,
                    'freeze_consumed' => false,
                ];
            }

            $lastDate = Carbon::parse($streak->getRawOriginal('last_completed_date') ?? $streak->last_completed_date, $timezone)->startOfDay();

            // 2. Already checked in on the same date (Idempotent)
            if ($lastDate->equalTo($today)) {
                return [
                    'streak' => $streak,
                    'incremented' => false,
                    'freeze_consumed' => false,
                ];
            }

            // 3. Consecutive Day Check-in (Yesterday -> Today)
            $daysDiff = (int) $lastDate->diffInDays($today);

            if ($daysDiff === 1) {
                $streak->current_streak += 1;
                if ($streak->current_streak > $streak->longest_streak) {
                    $streak->longest_streak = $streak->current_streak;
                }

                // Award freeze on every 7-day milestone
                if ($streak->current_streak % self::FREEZE_EARN_INTERVAL_DAYS === 0) {
                    if ($streak->freeze_count < self::MAX_FREEZE_INVENTORY) {
                        $streak->freeze_count += 1;
                    }
                }

                $streak->last_completed_date = $today->toDateString();
                $streak->save();

                return [
                    'streak' => $streak,
                    'incremented' => true,
                    'freeze_consumed' => false,
                ];
            }

            // 4. Missed Days Handling
            // If exactly 1 day was missed (daysDiff === 2) and user has a freeze
            if ($daysDiff === 2 && $streak->freeze_count > 0) {
                $yesterday = $today->copy()->subDay();

                // Consume Streak Freeze
                $streak->freeze_count -= 1;
                $streak->current_streak += 1;
                if ($streak->current_streak > $streak->longest_streak) {
                    $streak->longest_streak = $streak->current_streak;
                }
                $streak->last_completed_date = $today->toDateString();
                $streak->save();

                // Log freeze consumption
                StreakFreeze::create([
                    'user_id' => $user->id,
                    'streak_id' => $streak->id,
                    'used_for_date' => $yesterday->toDateString(),
                    'status' => 'used',
                    'used_at' => Carbon::now($timezone),
                ]);

                return [
                    'streak' => $streak,
                    'incremented' => true,
                    'freeze_consumed' => true,
                ];
            }

            // Multiple days missed or zero freezes available: Reset to 1
            $streak->current_streak = 1;
            $streak->last_completed_date = $today->toDateString();
            $streak->save();

            return [
                'streak' => $streak,
                'incremented' => true,
                'freeze_consumed' => false,
            ];
        });
    }

    /**
     * Checks if a user's streak is currently at risk for today in their timezone.
     */
    public function isStreakAtRisk(User $user, ?int $habitId = null): bool
    {
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();

        $streak = Streak::where('user_id', $user->id)
            ->where('habit_id', $habitId)
            ->first();

        if (!$streak || $streak->current_streak === 0) {
            return false;
        }

        return $streak->last_completed_date !== $today;
    }
}
