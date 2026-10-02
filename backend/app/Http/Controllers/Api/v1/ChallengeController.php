<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Challenge\StartChallengeRequest;
use App\Http\Requests\Challenge\ToggleTaskRequest;
use App\Http\Resources\ChallengeTemplateResource;
use App\Http\Resources\UserChallengeResource;
use App\Http\Resources\UserChallengeTaskResource;
use App\Http\Responses\ApiResponse;
use App\Models\ChallengeTemplate;
use App\Models\UserChallenge;
use App\Models\UserChallengeTask;
use App\Services\ChallengeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    /**
     * List all available official and community challenge templates.
     */
    public function listTemplates(): JsonResponse
    {
        $templates = ChallengeTemplate::where('is_active', true)->orderBy('duration_days')->get();

        return ApiResponse::success(
            data: ChallengeTemplateResource::collection($templates),
            message: 'Challenge templates retrieved successfully.'
        );
    }

    /**
     * Get details and curriculum syllabus of a challenge template.
     */
    public function getTemplate(int $id): JsonResponse
    {
        $template = ChallengeTemplate::with(['tasks' => fn ($q) => $q->orderBy('day_number')])
            ->findOrFail($id);

        return ApiResponse::success(
            data: new ChallengeTemplateResource($template),
            message: 'Challenge template syllabus retrieved.'
        );
    }

    /**
     * Enroll in and start a challenge template.
     */
    public function startChallenge(StartChallengeRequest $request, ChallengeService $service): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $template = ChallengeTemplate::findOrFail($validated['template_id']);

        $userChallenge = $service->startChallenge(
            user: $user,
            template: $template,
            startDate: $validated['start_date'] ?? null
        );

        return ApiResponse::success(
            data: new UserChallengeResource($userChallenge),
            message: 'Enrolled in challenge successfully.',
            statusCode: 201
        );
    }

    /**
     * Get user's currently active challenge.
     */
    public function getActiveChallenge(Request $request): JsonResponse
    {
        $active = UserChallenge::where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->with(['template', 'tasks'])
            ->first();

        if (!$active) {
            return ApiResponse::error(
                message: 'No active challenge in progress.',
                errorCode: 'NO_ACTIVE_CHALLENGE',
                statusCode: 404
            );
        }

        return ApiResponse::success(
            data: new UserChallengeResource($active),
            message: 'Active challenge retrieved.'
        );
    }

    /**
     * Get tasks scheduled specifically for the current active challenge day.
     */
    public function getTodayTasks(Request $request): JsonResponse
    {
        $activeChallenge = UserChallenge::where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->first();

        if (!$activeChallenge) {
            return ApiResponse::success(
                data: [],
                message: 'No active challenge found.'
            );
        }

        $tasks = UserChallengeTask::where('user_challenge_id', $activeChallenge->id)
            ->where('day_number', $activeChallenge->current_day)
            ->orderBy('id')
            ->get();

        return ApiResponse::success(
            data: UserChallengeTaskResource::collection($tasks),
            message: 'Today\'s challenge tasks retrieved.'
        );
    }

    /**
     * Toggle completion status of an enrolled challenge task.
     */
    public function toggleTask(ToggleTaskRequest $request, int $taskId, ChallengeService $service): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $result = $service->toggleTask(
            user: $user,
            userChallengeTaskId: $taskId,
            completed: (bool) $validated['is_completed']
        );

        return ApiResponse::success(
            data: [
                'task' => new UserChallengeTaskResource($result['task']),
                'challenge_progress_percentage' => $result['challenge_progress_percentage'],
                'gamification' => $result['gamification'],
            ],
            message: 'Task status updated.'
        );
    }
}
