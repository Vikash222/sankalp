<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\GuestAuthRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\UpgradeAccountRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\NotificationSetting;
use App\Models\Streak;
use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Register a new permanent user account.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = DB::transaction(function () use ($validated) {
            $user = User::create([
                'uuid' => (string) Str::uuid(),
                'name' => $validated['name'],
                'email' => strtolower($validated['email']),
                'password' => Hash::make($validated['password']),
                'is_guest' => false,
            ]);

            UserProfile::create([
                'user_id' => $user->id,
                'language' => $validated['language'] ?? 'en',
                'theme' => 'day', // Default theme: Yellow and White
                'timezone' => $validated['timezone'] ?? 'Asia/Kolkata',
            ]);

            NotificationSetting::create([
                'user_id' => $user->id,
                'morning_enabled' => true,
                'morning_time' => '05:30:00',
                'midday_enabled' => true,
                'midday_time' => '13:00:00',
                'evening_enabled' => true,
                'evening_time' => '21:00:00',
            ]);

            Streak::create([
                'user_id' => $user->id,
                'habit_id' => null,
                'current_streak' => 0,
                'longest_streak' => 0,
                'freeze_count' => 2,
            ]);

            return $user;
        });

        $token = $user->createToken('sankalp_auth_token')->plainTextToken;

        return ApiResponse::success(
            data: [
                'user' => new UserResource($user->load('profile')),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
            message: 'User registration completed successfully.',
            statusCode: 201
        );
    }

    /**
     * Authenticate an existing user via email and password.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::where('email', strtolower($validated['email']))->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return ApiResponse::error(
                message: 'Invalid email or password credentials provided.',
                errorCode: 'INVALID_CREDENTIALS',
                statusCode: 401
            );
        }

        $token = $user->createToken('sankalp_auth_token')->plainTextToken;

        return ApiResponse::success(
            data: [
                'user' => new UserResource($user->load('profile')),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
            message: 'Authentication successful.'
        );
    }

    /**
     * Authenticate an instant anonymous guest user to remove friction.
     */
    public function guest(GuestAuthRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $deviceUuid = $validated['device_uuid'];

        // Find or create guest user
        $user = DB::transaction(function () use ($deviceUuid, $validated) {
            $user = User::create([
                'uuid' => (string) Str::uuid(),
                'name' => 'Seeker ' . substr($deviceUuid, 0, 4),
                'email' => null,
                'password' => null,
                'is_guest' => true,
            ]);

            UserProfile::create([
                'user_id' => $user->id,
                'language' => $validated['language'] ?? 'en',
                'theme' => 'day', // Default theme: Yellow and White
                'timezone' => $validated['timezone'] ?? 'Asia/Kolkata',
            ]);

            NotificationSetting::create([
                'user_id' => $user->id,
                'morning_enabled' => true,
                'morning_time' => '05:30:00',
            ]);

            Streak::create([
                'user_id' => $user->id,
                'habit_id' => null,
                'current_streak' => 0,
                'longest_streak' => 0,
                'freeze_count' => 2,
            ]);

            return $user;
        });

        $token = $user->createToken('sankalp_guest_token')->plainTextToken;

        return ApiResponse::success(
            data: [
                'user' => new UserResource($user->load('profile')),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
            message: 'Guest session initialized successfully.',
            statusCode: 201
        );
    }

    /**
     * Convert an anonymous guest account into a permanent account.
     */
    public function upgrade(UpgradeAccountRequest $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->is_guest) {
            return ApiResponse::error(
                message: 'Account is already a registered permanent account.',
                errorCode: 'ALREADY_PERMANENT',
                statusCode: 400
            );
        }

        $validated = $request->validated();

        $user->update([
            'name' => $validated['name'],
            'email' => strtolower($validated['email']),
            'password' => Hash::make($validated['password']),
            'is_guest' => false,
        ]);

        return ApiResponse::success(
            data: [
                'user' => new UserResource($user->load('profile')),
            ],
            message: 'Guest account successfully converted to permanent profile.'
        );
    }

    /**
     * Retrieve the authenticated user profile and discipline overview.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['profile', 'streaks' => fn ($q) => $q->whereNull('habit_id')]);

        return ApiResponse::success(
            data: [
                'user' => new UserResource($user),
                'streak' => $user->streaks->first(),
            ],
            message: 'User profile retrieved.'
        );
    }

    /**
     * Invalidate the current session token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return ApiResponse::success(
            data: null,
            message: 'Logged out successfully.'
        );
    }
}
