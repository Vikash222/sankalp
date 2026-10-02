<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Resources\BadgeResource;
use App\Http\Responses\ApiResponse;
use App\Models\Badge;
use App\Models\User;
use App\Services\GamificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GamificationController extends Controller
{
    /**
     * Retrieve gamification profile including level, progress bar, and badge count.
     */
    public function profile(Request $request, GamificationService $service): JsonResponse
    {
        $summary = $service->getGamificationSummary($request->user());

        return ApiResponse::success(
            data: $summary,
            message: 'Gamification profile retrieved.'
        );
    }

    /**
     * Retrieve catalog of 30 badges with user unlocked state.
     */
    public function badges(Request $request): JsonResponse
    {
        $user = $request->user();
        $unlockedBadges = DB::table('user_badges')
            ->where('user_id', $user->id)
            ->pluck('unlocked_at', 'badge_id');

        $allBadges = Badge::orderBy('tier')->orderBy('id')->get()->map(function ($badge) use ($unlockedBadges) {
            $isUnlocked = isset($unlockedBadges[$badge->id]);
            return [
                'id' => $badge->id,
                'slug' => $badge->slug,
                'name' => $badge->name,
                'description' => $badge->description,
                'category' => $badge->category,
                'tier' => $badge->tier,
                'icon_name' => $badge->icon_name,
                'xp_bonus' => $badge->xp_bonus,
                'is_unlocked' => $isUnlocked,
                'unlocked_at' => $isUnlocked ? $unlockedBadges[$badge->id] : null,
            ];
        });

        return ApiResponse::success(
            data: $allBadges,
            message: 'Badge catalog retrieved.'
        );
    }

    /**
     * Retrieve discipline leaderboard ranked by total XP.
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $leaderboard = DB::table('users')
            ->join('xp_transactions', 'users.id', '=', 'xp_transactions.user_id')
            ->leftJoin('user_profiles', 'users.id', '=', 'user_profiles.user_id')
            ->select(
                'users.id',
                'users.name',
                'user_profiles.avatar_url',
                DB::raw('SUM(xp_transactions.amount) as total_xp')
            )
            ->groupBy('users.id', 'users.name', 'user_profiles.avatar_url')
            ->orderByDesc('total_xp')
            ->limit(50)
            ->get()
            ->map(function ($row, $index) {
                return [
                    'rank' => $index + 1,
                    'user_id' => $row->id,
                    'name' => $row->name ?: 'Anonymous Practitioner',
                    'avatar_url' => $row->avatar_url,
                    'total_xp' => (int) $row->total_xp,
                ];
            });

        return ApiResponse::success(
            data: $leaderboard,
            message: 'Discipline leaderboard retrieved.'
        );
    }
}
