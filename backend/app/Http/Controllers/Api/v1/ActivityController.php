<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Activity\RecordActivityRequest;
use App\Http\Resources\ActivityResource;
use App\Http\Resources\PersonalRecordResource;
use App\Http\Responses\ApiResponse;
use App\Models\Activity;
use App\Models\PersonalRecord;
use App\Services\ActivityService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ActivityController extends Controller
{
    /**
     * Retrieve paginated history of GPS activities.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Activity::where('user_id', $request->user()->id)
            ->with('splits')
            ->latest('started_at');

        if ($request->filled('type')) {
            $query->where('type', strtolower($request->input('type')));
        }

        if ($request->filled('from_date')) {
            $query->where('started_at', '>=', $request->input('from_date'));
        }

        if ($request->filled('to_date')) {
            $query->where('started_at', '<=', $request->input('to_date'));
        }

        $activities = $query->paginate($request->input('per_page', 15));

        return ApiResponse::paginated(
            paginator: $activities,
            resourceClass: ActivityResource::class,
            message: 'Activities retrieved successfully.'
        );
    }

    /**
     * Submit and persist a GPS workout session idempotently.
     */
    public function store(RecordActivityRequest $request, ActivityService $service): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $result = $service->recordActivity($user, $validated);

        return ApiResponse::success(
            data: [
                'activity' => new ActivityResource($result['activity']),
                'is_duplicate' => $result['is_duplicate'],
                'is_flagged' => $result['is_flagged'],
                'gamification' => $result['gamification'],
            ],
            message: $result['is_duplicate'] ? 'Activity already synchronized.' : ($result['is_flagged'] ? 'Activity flagged as vehicle movement.' : 'Activity recorded successfully.'),
            statusCode: $result['is_duplicate'] ? 200 : 201
        );
    }

    /**
     * Retrieve full details of an activity including polyline and splits.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $activity = Activity::where('user_id', $request->user()->id)
            ->with('splits')
            ->findOrFail($id);

        return ApiResponse::success(
            data: new ActivityResource($activity),
            message: 'Activity details retrieved.'
        );
    }

    /**
     * Delete an activity record.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $activity = Activity::where('user_id', $request->user()->id)->findOrFail($id);
        $activity->delete();

        return ApiResponse::success(
            data: null,
            message: 'Activity deleted successfully.'
        );
    }

    /**
     * Retrieve aggregate statistics (weekly, monthly, all-time).
     */
    public function stats(Request $request): JsonResponse
    {
        $user = $request->user();
        $now = Carbon::now();

        $allTime = Activity::where('user_id', $user->id)->where('source', '!=', 'flagged_vehicle');
        $totalDistance = (float) $allTime->sum('distance_m');
        $totalMovingTime = (int) $allTime->sum('moving_time_s');
        $totalCalories = (int) $allTime->sum('calories');
        $totalWorkouts = $allTime->count();

        $thisWeek = Activity::where('user_id', $user->id)
            ->where('source', '!=', 'flagged_vehicle')
            ->where('started_at', '>=', $now->copy()->startOfWeek());

        $thisMonth = Activity::where('user_id', $user->id)
            ->where('source', '!=', 'flagged_vehicle')
            ->where('started_at', '>=', $now->copy()->startOfMonth());

        return ApiResponse::success(
            data: [
                'all_time' => [
                    'total_distance_m' => $totalDistance,
                    'total_moving_time_s' => $totalMovingTime,
                    'total_calories' => $totalCalories,
                    'total_workouts' => $totalWorkouts,
                ],
                'this_week' => [
                    'distance_m' => (float) $thisWeek->sum('distance_m'),
                    'moving_time_s' => (int) $thisWeek->sum('moving_time_s'),
                    'calories' => (int) $thisWeek->sum('calories'),
                    'workouts' => $thisWeek->count(),
                ],
                'this_month' => [
                    'distance_m' => (float) $thisMonth->sum('distance_m'),
                    'moving_time_s' => (int) $thisMonth->sum('moving_time_s'),
                    'calories' => (int) $thisMonth->sum('calories'),
                    'workouts' => $thisMonth->count(),
                ],
            ],
            message: 'Activity statistics retrieved.'
        );
    }

    /**
     * Retrieve personal records.
     */
    public function records(Request $request): JsonResponse
    {
        $records = PersonalRecord::where('user_id', $request->user()->id)->get();

        return ApiResponse::success(
            data: PersonalRecordResource::collection($records),
            message: 'Personal records retrieved.'
        );
    }

    /**
     * Export activity route in standard GPX format.
     */
    public function exportGpx(Request $request, int $id, ActivityService $service): Response
    {
        $activity = Activity::where('user_id', $request->user()->id)->findOrFail($id);
        $gpxXml = $service->exportGpx($activity);

        return response($gpxXml, 200, [
            'Content-Type' => 'application/gpx+xml',
            'Content-Disposition' => 'attachment; filename="sankalp_activity_' . $activity->id . '.gpx"',
        ]);
    }
}
