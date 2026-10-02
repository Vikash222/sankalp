<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Quiz\SubmitQuizRequest;
use App\Http\Resources\QuizQuestionResource;
use App\Http\Resources\RoadmapResource;
use App\Http\Responses\ApiResponse;
use App\Models\QuizQuestion;
use App\Services\QuizRoadmapService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuizController extends Controller
{
    /**
     * Fetch the 16-question lifestyle diagnosis test with options.
     */
    public function getQuestions(Request $request): JsonResponse
    {
        $questions = QuizQuestion::with('options')
            ->orderBy('order_number')
            ->get();

        return ApiResponse::success(
            data: QuizQuestionResource::collection($questions),
            message: 'Quiz questions retrieved successfully.'
        );
    }

    /**
     * Submit diagnostic quiz responses, compute archetype, and generate personalized roadmap.
     */
    public function submitQuiz(SubmitQuizRequest $request, QuizRoadmapService $service): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $result = $service->evaluateAndGenerateRoadmap($user, $validated['answers']);

        return ApiResponse::success(
            data: [
                'archetype' => $result['archetype'],
                'life_balance_index' => $result['life_balance_index'],
                'target_challenge_slug' => $result['target_challenge_slug'],
                'roadmap' => new RoadmapResource($result['roadmap']),
            ],
            message: 'Quiz evaluated and personal transformation roadmap generated.',
            statusCode: 201
        );
    }
}
