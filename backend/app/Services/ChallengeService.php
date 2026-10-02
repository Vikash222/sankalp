<?php

namespace App\Services;

use App\Models\ChallengeTemplate;
use App\Models\User;
use App\Models\UserChallenge;
use App\Models\UserChallengeTask;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class ChallengeService
{
    public function __construct(
        protected StreakService $streakService,
        protected GamificationService $gamificationService,
    ) {}

    /**
     * Start a challenge template for the user, cloning all curriculum tasks.
     */
    public function startChallenge(
        User $user,
        ChallengeTemplate $template,
        ?string $startDate = null
    ): UserChallenge {
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $start = $startDate ? Carbon::parse($startDate, $timezone) : Carbon::now($timezone);

        return DB::transaction(function () use ($user, $template, $start, $timezone) {
            // Deactivate any currently active instance of this template
            UserChallenge::where('user_id', $user->id)
                ->where('challenge_template_id', $template->id)
                ->where('status', 'active')
                ->update(['status' => 'abandoned']);

            $userChallenge = UserChallenge::create([
                'user_id' => $user->id,
                'challenge_template_id' => $template->id,
                'status' => 'active',
                'started_at' => $start->toDateString(),
                'current_day' => 1,
            ]);

            // Clone all template tasks
            $templateTasks = $template->tasks()->orderBy('day_number')->get();

            $insertData = [];
            foreach ($templateTasks as $tTask) {
                $insertData[] = [
                    'user_challenge_id' => $userChallenge->id,
                    'user_id' => $user->id,
                    'day_number' => $tTask->day_number,
                    'task_title' => $tTask->title,
                    'task_title_hi' => $tTask->title_hi ?? $tTask->title,
                    'is_completed' => false,
                    'completed_at' => null,
                    'xp_awarded' => 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            if (!empty($insertData)) {
                foreach (array_chunk($insertData, 100) as $chunk) {
                    UserChallengeTask::insert($chunk);
                }
            }

            return $userChallenge->fresh(['tasks', 'template']);
        });
    }

    /**
     * Toggle completion status of a user's challenge task.
     */
    public function toggleTask(User $user, int $userChallengeTaskId, bool $completed): array
    {
        $task = UserChallengeTask::with('userChallenge.template')->findOrFail($userChallengeTaskId);

        if ($task->user_id !== $user->id) {
            throw new AccessDeniedHttpException('You are not authorized to modify this challenge task.');
        }

        return DB::transaction(function () use ($user, $task, $completed) {
            $task->update([
                'is_completed' => $completed,
                'completed_at' => $completed ? now() : null,
                'xp_awarded' => $completed ? 15 : 0,
            ]);

            $gamificationResult = null;
            $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
            $today = Carbon::now($timezone)->toDateString();

            if ($completed) {
                // Award XP for completing the task
                $gamificationResult = $this->gamificationService->awardXp(
                    user: $user,
                    amount: 15,
                    reason: 'Completed challenge task: ' . $task->task_title,
                    referenceType: 'user_challenge_task',
                    referenceId: $task->id
                );

                // Check if all tasks for this day are completed
                $remainingToday = UserChallengeTask::where('user_challenge_id', $task->user_challenge_id)
                    ->where('day_number', $task->day_number)
                    ->where('is_completed', false)
                    ->count();

                if ($remainingToday === 0) {
                    // Daily bonus award
                    $bonus = $this->gamificationService->awardXp(
                        user: $user,
                        amount: 50,
                        reason: 'All tasks completed for Day ' . $task->day_number,
                        referenceType: 'user_challenge_day',
                        referenceId: $task->user_challenge_id
                    );

                    // Update overall streak
                    $this->streakService->recordDailyCompletion(
                        user: $user,
                        scope: 'challenge',
                        scopeId: $task->user_challenge_id,
                        completionDate: $today,
                        userTimezone: $timezone
                    );

                    $gamificationResult['total_xp'] = $bonus['total_xp'];
                    $gamificationResult['awarded_xp'] += 50;

                    // Advance user challenge current day if applicable
                    $userChallenge = $task->userChallenge;
                    if ($userChallenge->current_day <= $task->day_number) {
                        $userChallenge->update(['current_day' => $task->day_number + 1]);
                    }
                }

                // Check overall challenge completion
                $totalTasks = UserChallengeTask::where('user_challenge_id', $task->user_challenge_id)->count();
                $completedTasks = UserChallengeTask::where('user_challenge_id', $task->user_challenge_id)
                    ->where('is_completed', true)
                    ->count();

                if ($totalTasks > 0 && $completedTasks === $totalTasks) {
                    $task->userChallenge->update([
                        'status' => 'completed',
                        'completed_at' => $today,
                    ]);

                    $templateSlug = $task->userChallenge->template?->slug;
                    $finishXp = 500;
                    $finishBadge = null;

                    if ($templateSlug === '21-day-habit-builder') {
                        $finishXp = 500;
                        $finishBadge = 'finisher_21';
                    } elseif ($templateSlug === '90-day-transformation') {
                        $finishXp = 2500;
                        $finishBadge = 'finisher_90';
                    } elseif ($templateSlug === 'summer-arc') {
                        $finishXp = 1500;
                        $finishBadge = 'summer_arc_champion';
                    } elseif ($templateSlug === 'winter-arc') {
                        $finishXp = 2000;
                        $finishBadge = 'winter_arc_champion';
                    }

                    $finalBonus = $this->gamificationService->awardXp(
                        user: $user,
                        amount: $finishXp,
                        reason: 'Completed challenge: ' . ($task->userChallenge->template?->title ?? 'Sankalp Challenge'),
                        referenceType: 'user_challenge_completed',
                        referenceId: $task->user_challenge_id
                    );

                    if ($finishBadge) {
                        $b = $this->gamificationService->unlockBadge($user, $finishBadge);
                        if ($b) $finalBonus['newly_unlocked_badges'][] = $b;
                    }

                    $gamificationResult = $finalBonus;
                }
            }

            // Compute current completion percentage
            $total = UserChallengeTask::where('user_challenge_id', $task->user_challenge_id)->count();
            $done = UserChallengeTask::where('user_challenge_id', $task->user_challenge_id)->where('is_completed', true)->count();
            $pct = $total > 0 ? round(($done / $total) * 100, 1) : 0.0;

            return [
                'task' => $task->fresh(),
                'challenge_progress_percentage' => $pct,
                'gamification' => $gamificationResult,
            ];
        });
    }
}
