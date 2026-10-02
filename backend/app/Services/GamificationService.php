<?php

namespace App\Services;

use App\Models\Badge;
use App\Models\Level;
use App\Models\User;
use App\Models\UserBadge;
use App\Models\XpTransaction;
use Illuminate\Support\Facades\DB;

class GamificationService
{
    /**
     * Award XP to a user, recalculate current level, and evaluate milestone badges.
     */
    public function awardXp(
        User $user,
        int $amount,
        string $reason,
        ?string $referenceType = null,
        ?int $referenceId = null
    ): array {
        return DB::transaction(function () use ($user, $amount, $reason, $referenceType, $referenceId) {
            // 1. Create XP transaction record
            XpTransaction::create([
                'user_id' => $user->id,
                'amount' => $amount,
                'description' => $reason,
                'source_type' => $referenceType ?? 'discipline',
                'source_id' => $referenceId,
            ]);

            // 2. Compute total XP
            $totalXp = (int) $user->xpTransactions()->sum('amount');

            // 3. Determine current level from levels table
            $currentLevel = Level::where('min_xp', '<=', $totalXp)
                ->orderByDesc('level_number')
                ->first();

            if (!$currentLevel) {
                $currentLevel = Level::orderBy('level_number')->first();
            }

            $currentLevelNumber = $currentLevel ? $currentLevel->level_number : 1;
            $currentLevelTitle = $currentLevel ? $currentLevel->title : 'Novice';

            // 4. Identify next level threshold
            $nextLevel = Level::where('level_number', '>', $currentLevelNumber)
                ->orderBy('level_number')
                ->first();

            // 5. Evaluate milestone badges based on level
            $newlyUnlockedBadges = [];

            if ($currentLevelNumber >= 5) {
                $badge = $this->unlockBadge($user, 'level_5');
                if ($badge) $newlyUnlockedBadges[] = $badge;
            }
            if ($currentLevelNumber >= 10) {
                $badge = $this->unlockBadge($user, 'level_10');
                if ($badge) $newlyUnlockedBadges[] = $badge;
            }
            if ($currentLevelNumber >= 25) {
                $badge = $this->unlockBadge($user, 'level_25');
                if ($badge) $newlyUnlockedBadges[] = $badge;
            }
            if ($currentLevelNumber >= 50) {
                $badge = $this->unlockBadge($user, 'level_50');
                if ($badge) $newlyUnlockedBadges[] = $badge;
            }

            return [
                'awarded_xp' => $amount,
                'total_xp' => $totalXp,
                'current_level' => $currentLevelNumber,
                'level_title' => $currentLevelTitle,
                'next_level_xp' => $nextLevel ? $nextLevel->min_xp : null,
                'xp_to_next_level' => $nextLevel ? max(0, $nextLevel->min_xp - $totalXp) : 0,
                'newly_unlocked_badges' => $newlyUnlockedBadges,
            ];
        });
    }

    /**
     * Safely unlock a badge for a user idempotently.
     */
    public function unlockBadge(User $user, string $badgeSlug): ?Badge
    {
        $badge = Badge::where('slug', $badgeSlug)->first();
        if (!$badge) {
            return null;
        }

        $alreadyUnlocked = UserBadge::where('user_id', $user->id)
            ->where('badge_id', $badge->id)
            ->exists();

        if ($alreadyUnlocked) {
            return null;
        }

        UserBadge::create([
            'user_id' => $user->id,
            'badge_id' => $badge->id,
            'unlocked_at' => now(),
        ]);

        return $badge;
    }

    /**
     * Return comprehensive gamification telemetry for a user profile.
     */
    public function getGamificationSummary(User $user): array
    {
        $totalXp = (int) $user->xpTransactions()->sum('amount');

        $currentLevel = Level::where('min_xp', '<=', $totalXp)
            ->orderByDesc('level_number')
            ->first();

        if (!$currentLevel) {
            $currentLevel = Level::orderBy('level_number')->first();
        }

        $currentLevelNumber = $currentLevel ? $currentLevel->level_number : 1;
        $currentLevelTitle = $currentLevel ? $currentLevel->title : 'Initiate';
        $currentMinXp = $currentLevel ? $currentLevel->min_xp : 0;

        $nextLevel = Level::where('level_number', '>', $currentLevelNumber)
            ->orderBy('level_number')
            ->first();

        $nextLevelXp = $nextLevel ? $nextLevel->min_xp : $totalXp;
        $xpIntoLevel = max(0, $totalXp - $currentMinXp);
        $levelSpan = max(1, $nextLevelXp - $currentMinXp);
        $progressPct = $nextLevel ? round(($xpIntoLevel / $levelSpan) * 100, 1) : 100.0;

        $unlockedBadges = $user->badges()->get();
        $unlockedIds = $unlockedBadges->pluck('id')->toArray();
        $allBadges = Badge::orderBy('tier')->get();

        return [
            'total_xp' => $totalXp,
            'level' => $currentLevelNumber,
            'level_title' => $currentLevelTitle,
            'current_level_min_xp' => $currentMinXp,
            'next_level_xp' => $nextLevelXp,
            'xp_to_next_level' => $nextLevel ? max(0, $nextLevelXp - $totalXp) : 0,
            'level_progress_percentage' => min(100.0, $progressPct),
            'badges_count' => count($unlockedIds),
            'total_available_badges' => $allBadges->count(),
            'unlocked_badges' => $unlockedBadges,
            'recent_xp_transactions' => $user->xpTransactions()->latest()->limit(10)->get(),
        ];
    }
}
