<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Habit\CheckInHabitRequest;
use App\Http\Requests\Habit\CreateHabitRequest;
use App\Http\Resources\HabitLogResource;
use App\Http\Resources\HabitResource;
use App\Http\Responses\ApiResponse;
use App\Models\Habit;
use App\Models\Streak;
use App\Services\HabitService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class HabitController extends Controller
{
    /**
     * List all active habits configured by the user.
     */
    public function index(Request $request): JsonResponse
    {
        $habits = Habit::where('user_id', $request->user()->id)
            ->where('is_active', true)
            ->with(['streak', 'logs'])
            ->latest()
            ->get();

        return ApiResponse::success(
            data: HabitResource::collection($habits),
            message: 'Habits retrieved successfully.'
        );
    }

    /**
     * Create a new custom or templated habit.
     */
    public function store(CreateHabitRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();
        $habit = Habit::create(array_merge($validated, [
            'user_id' => $user->id,
            'is_active' => true,
        ]));

        // Initialize dedicated streak tracker
        Streak::create([
            'user_id' => $user->id,
            'habit_id' => $habit->id,
            'current_streak' => 0,
            'longest_streak' => 0,
            'freeze_count' => 0,
        ]);

        return ApiResponse::success(
            data: new HabitResource($habit),
            message: 'Habit created successfully.',
            statusCode: 201
        );
    }

    /**
     * Retrieve single habit details.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $habit = Habit::where('user_id', $request->user()->id)->findOrFail($id);

        return ApiResponse::success(
            data: new HabitResource($habit),
            message: 'Habit details retrieved.'
        );
    }

    /**
     * Update an existing habit.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $habit = Habit::where('user_id', $request->user()->id)->findOrFail($id);

        $validated = $request->validate([
            'title' => ['nullable', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
            'category' => ['nullable', 'string'],
            'frequency' => ['nullable', 'string'],
            'target_days' => ['nullable', 'array'],
            'target_time' => ['nullable', 'string'],
            'reminder_time' => ['nullable', 'string'],
            'numeric_target' => ['nullable', 'integer'],
            'unit' => ['nullable', 'string'],
        ]);

        $habit->update($validated);

        return ApiResponse::success(
            data: new HabitResource($habit),
            message: 'Habit updated successfully.'
        );
    }

    /**
     * Archive/delete a habit.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $habit = Habit::where('user_id', $request->user()->id)->findOrFail($id);
        $habit->update(['is_active' => false]);

        return ApiResponse::success(
            data: null,
            message: 'Habit archived successfully.'
        );
    }

    /**
     * Perform daily check-in for a habit, updating streaks and awarding XP.
     */
    public function checkin(CheckInHabitRequest $request, int $id, HabitService $service): JsonResponse
    {
        $user = $request->user();
        $habit = Habit::findOrFail($id);

        if ($habit->user_id !== $user->id) {
            throw new AccessDeniedHttpException('You do not have permission to check in to this habit.');
        }

        $validated = $request->validated();

        $result = $service->checkIn(
            user: $user,
            habit: $habit,
            date: $validated['date'] ?? null,
            notes: $validated['notes'] ?? null,
            numericValue: $validated['numeric_value'] ?? null
        );

        return ApiResponse::success(
            data: [
                'habit_log' => new HabitLogResource($result['habit_log']),
                'current_streak' => $result['habit_streak']->current_streak,
                'longest_streak' => $result['habit_streak']->longest_streak,
                'overall_streak' => $result['overall_streak']->current_streak,
                'gamification' => $result['gamification'],
            ],
            message: 'Habit check-in recorded successfully.'
        );
    }

    /**
     * Get annual completion heatmap.
     */
    public function heatmap(Request $request, int $id, HabitService $service): JsonResponse
    {
        $habit = Habit::where('user_id', $request->user()->id)->findOrFail($id);
        $year = $request->query('year') ? (int) $request->query('year') : null;

        $heatmapData = $service->getHeatmap($habit, $year);

        return ApiResponse::success(
            data: $heatmapData,
            message: 'Heatmap data retrieved.'
        );
    }
}
