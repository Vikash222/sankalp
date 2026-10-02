<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Detox\StoreBlockedAppRuleRequest;
use App\Http\Resources\BlockedAppRuleResource;
use App\Http\Responses\ApiResponse;
use App\Models\BlockedAppRule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BlockedAppRuleController extends Controller
{
    /**
     * List all blocked app restrictions for user.
     */
    public function index(Request $request): JsonResponse
    {
        $rules = BlockedAppRule::where('user_id', $request->user()->id)->get();

        return ApiResponse::success(
            data: BlockedAppRuleResource::collection($rules),
            message: 'Blocked app rules retrieved.'
        );
    }

    /**
     * Store or update an app restriction rule.
     */
    public function store(StoreBlockedAppRuleRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $rule = BlockedAppRule::updateOrCreate(
            [
                'user_id' => $user->id,
                'package_name' => $validated['package_name'],
            ],
            [
                'app_name' => $validated['app_name'],
                'is_blocked' => $validated['is_blocked'] ?? true,
                'daily_limit_minutes' => $validated['daily_limit_minutes'] ?? 0,
            ]
        );

        return ApiResponse::success(
            data: new BlockedAppRuleResource($rule),
            message: 'App blocking rule saved.',
            statusCode: 201
        );
    }

    /**
     * Delete an app restriction rule.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $rule = BlockedAppRule::where('user_id', $request->user()->id)->findOrFail($id);
        $rule->delete();

        return ApiResponse::success(
            data: null,
            message: 'App blocking rule removed.'
        );
    }
}
