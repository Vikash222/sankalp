<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\UpdateProfileRequest;
use App\Http\Resources\UserProfileResource;
use App\Http\Responses\ApiResponse;
use App\Models\NotificationSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserProfileController extends Controller
{
    /**
     * Retrieve user profile details.
     */
    public function getProfile(Request $request): JsonResponse
    {
        $profile = $request->user()->profile ?? $request->user()->profile()->create([
            'language' => 'en',
            'theme' => 'day',
            'timezone' => 'Asia/Kolkata',
        ]);

        return ApiResponse::success(
            data: new UserProfileResource($profile),
            message: 'User profile retrieved successfully.'
        );
    }

    /**
     * Update user profile attributes including theme, physical stats, and timezone.
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        if (isset($validated['name'])) {
            $user->update(['name' => $validated['name']]);
            unset($validated['name']);
        }

        $profile = $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            $validated
        );

        return ApiResponse::success(
            data: new UserProfileResource($profile),
            message: 'User profile updated successfully.'
        );
    }

    /**
     * Retrieve notification schedule settings.
     */
    public function getNotificationSettings(Request $request): JsonResponse
    {
        $settings = $request->user()->notificationSettings ?? NotificationSetting::create([
            'user_id' => $request->user()->id,
            'morning_enabled' => true,
            'morning_time' => '05:30:00',
        ]);

        return ApiResponse::success(
            data: $settings,
            message: 'Notification settings retrieved.'
        );
    }

    /**
     * Update notification schedule settings.
     */
    public function updateNotificationSettings(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'morning_enabled' => ['nullable', 'boolean'],
            'morning_time' => ['nullable', 'string'],
            'midday_enabled' => ['nullable', 'boolean'],
            'midday_time' => ['nullable', 'string'],
            'evening_enabled' => ['nullable', 'boolean'],
            'evening_time' => ['nullable', 'string'],
            'bedtime_enabled' => ['nullable', 'boolean'],
            'bedtime_time' => ['nullable', 'string'],
            'streak_warning_enabled' => ['nullable', 'boolean'],
            'dnd_start_time' => ['nullable', 'string'],
            'dnd_end_time' => ['nullable', 'string'],
        ]);

        $settings = $request->user()->notificationSettings()->updateOrCreate(
            ['user_id' => $request->user()->id],
            $validated
        );

        return ApiResponse::success(
            data: $settings,
            message: 'Notification settings updated successfully.'
        );
    }
}
