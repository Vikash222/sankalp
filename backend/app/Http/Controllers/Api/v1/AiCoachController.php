<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ai\AiChatRequest;
use App\Http\Resources\AiMessageResource;
use App\Http\Responses\ApiResponse;
use App\Models\AiConversation;
use App\Services\AI\AiCoachService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiCoachController extends Controller
{
    /**
     * Converse with the Sankalp Discipline AI Coach.
     */
    public function chat(AiChatRequest $request, AiCoachService $service): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $result = $service->chat(
            user: $user,
            userMessage: $validated['message'],
            conversationId: $validated['conversation_id'] ?? null
        );

        return ApiResponse::success(
            data: [
                'conversation_id' => $result['conversation_id'],
                'message' => new AiMessageResource($result['message']),
                'model' => $result['model'],
            ],
            message: 'Coach guidance retrieved.',
            statusCode: 200
        );
    }

    /**
     * Retrieve all historical AI coaching sessions.
     */
    public function conversations(Request $request): JsonResponse
    {
        $conversations = AiConversation::where('user_id', $request->user()->id)
            ->withCount('messages')
            ->latest('updated_at')
            ->get();

        return ApiResponse::success(
            data: $conversations,
            message: 'Conversations retrieved.'
        );
    }

    /**
     * Retrieve messages for a specific conversation session.
     */
    public function messages(Request $request, int $conversationId): JsonResponse
    {
        $conversation = AiConversation::where('user_id', $request->user()->id)->findOrFail($conversationId);
        $messages = $conversation->messages()->orderBy('id')->get();

        return ApiResponse::success(
            data: AiMessageResource::collection($messages),
            message: 'Messages retrieved.'
        );
    }
}
