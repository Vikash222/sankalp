<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Resources\StreakResource;
use App\Http\Responses\ApiResponse;
use App\Models\Streak;
use App\Models\StreakFreeze;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StreakController extends Controller
{
    /**
     * Retrieve summary of user's overall streak, streak freezes, and comeback status.
     */
    public function getSummary(Request $request): JsonResponse
    {
        $user = $request->user();

        $overallStreak = Streak::where('user_id', $user->id)
            ->whereNull('habit_id')
            ->first();

        if (!$overallStreak) {
            $overallStreak = Streak::create([
                'user_id' => $user->id,
                'habit_id' => null,
                'current_streak' => 0,
                'longest_streak' => 0,
                'freeze_count' => 2,
            ]);
        }

        $habitStreaks = Streak::where('user_id', $user->id)
            ->whereNotNull('habit_id')
            ->with('habit')
            ->orderByDesc('current_streak')
            ->get();

        $freezeHistory = StreakFreeze::where('user_id', $user->id)->latest()->take(10)->get();

        return ApiResponse::success(
            data: [
                'overall_streak' => new StreakResource($overallStreak),
                'habit_streaks' => StreakResource::collection($habitStreaks),
                'available_freezes' => $overallStreak->freeze_count,
                'in_comeback_mode' => (bool) $overallStreak->in_comeback_mode,
                'freeze_history' => $freezeHistory,
            ],
            message: 'Streak summary retrieved successfully.'
        );
    }

    /**
     * Manually invoke a streak freeze for an emergency or sickness.
     */
    public function useFreeze(Request $request): JsonResponse
    {
        $user = $request->user();
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();

        $streak = Streak::where('user_id', $user->id)->whereNull('habit_id')->first();

        if (!$streak || $streak->freeze_count <= 0) {
            return ApiResponse::error(
                message: 'No streak freezes available. Complete challenges or earn freezes through consistency.',
                errorCode: 'NO_FREEZES_AVAILABLE',
                statusCode: 400
            );
        }

        $streak->decrement('freeze_count');

        $freeze = StreakFreeze::create([
            'user_id' => $user->id,
            'streak_id' => $streak->id,
            'frozen_date' => $today,
            'reason' => $request->input('reason', 'Emergency freeze manually applied'),
        ]);

        return ApiResponse::success(
            data: [
                'freeze' => $freeze,
                'remaining_freezes' => $streak->freeze_count,
            ],
            message: 'Streak freeze consumed successfully.'
        );
    }
}
