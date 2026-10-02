<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Resources\RoadmapResource;
use App\Http\Responses\ApiResponse;
use App\Models\Roadmap;
use App\Models\RoadmapPhase;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RoadmapController extends Controller
{
    /**
     * Retrieve the user's currently active personalized roadmap and phases.
     */
    public function getCurrent(Request $request): JsonResponse
    {
        $roadmap = Roadmap::where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->with(['phases' => fn ($q) => $q->orderBy('phase_number')])
            ->first();

        if (!$roadmap) {
            return ApiResponse::error(
                message: 'No active roadmap found. Please complete the diagnostic onboarding quiz.',
                errorCode: 'ROADMAP_NOT_FOUND',
                statusCode: 404
            );
        }

        return ApiResponse::success(
            data: new RoadmapResource($roadmap),
            message: 'Active roadmap retrieved successfully.'
        );
    }
}
