<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Detox\StoreFocusSessionRequest;
use App\Http\Resources\FocusSessionResource;
use App\Http\Responses\ApiResponse;
use App\Models\FocusSession;
use App\Services\GamificationService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FocusSessionController extends Controller
{
    /**
     * List user's focus sessions.
     */
    public function index(Request $request): JsonResponse
    {
        $sessions = FocusSession::where('user_id', $request->user()->id)
            ->latest('started_at')
            ->paginate($request->input('per_page', 20));

        return ApiResponse::paginated(
            paginator: $sessions,
            resourceClass: FocusSessionResource::class,
            message: 'Focus sessions retrieved.'
        );
    }

    /**
     * Record a completed focus / deep work session and award XP.
     */
    public function store(StoreFocusSessionRequest $request, GamificationService $gamification): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $durationMinutes = (int) $validated['duration_minutes'];
        $completedMinutes = isset($validated['completed_minutes']) ? (int) $validated['completed_minutes'] : $durationMinutes;
        $isSuccessful = $validated['is_successful'] ?? true;
        $startedAt = isset($validated['started_at']) ? Carbon::parse($validated['started_at']) : now()->subMinutes($durationMinutes);
        $endedAt = isset($validated['ended_at']) ? Carbon::parse($validated['ended_at']) : now();

        $session = FocusSession::create([
            'user_id' => $user->id,
            'duration_minutes' => $durationMinutes,
            'completed_minutes' => $completedMinutes,
            'mode' => $validated['mode'],
            'is_successful' => $isSuccessful,
            'started_at' => $startedAt,
            'ended_at' => $endedAt,
            'interruption_count' => $validated['interruption_count'] ?? 0,
        ]);

        $gamificationResult = null;
        if ($session->is_successful) {
            // Award 1 XP per minute of deep work
            $xp = max(10, (int) $session->completed_minutes);
            $gamificationResult = $gamification->awardXp(
                user: $user,
                amount: $xp,
                reason: 'Focus Session: ' . $session->completed_minutes . ' mins of ' . $session->mode,
                referenceType: 'focus_session',
                referenceId: $session->id
            );

            // Badges
            $totalMins = FocusSession::where('user_id', $user->id)->where('is_successful', true)->sum('completed_minutes');
            if ($totalMins >= 600) {
                $b = $gamification->unlockBadge($user, 'deep_work_master');
                if ($b) $gamificationResult['newly_unlocked_badges'][] = $b;
            }
        }

        return ApiResponse::success(
            data: [
                'session' => new FocusSessionResource($session),
                'gamification' => $gamificationResult,
            ],
            message: 'Focus session recorded successfully.',
            statusCode: 201
        );
    }
}
