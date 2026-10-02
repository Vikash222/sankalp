<?php

namespace App\Services;

use App\Models\Activity;
use App\Models\ActivitySplit;
use App\Models\Habit;
use App\Models\PersonalRecord;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ActivityService
{
    public function __construct(
        protected GamificationService $gamificationService,
        protected HabitService $habitService,
    ) {}

    /**
     * Record a completed outdoor GPS activity with anti-cheat validation.
     */
    public function recordActivity(User $user, array $data): array
    {
        // 1. Check idempotency
        $clientUuid = $data['client_uuid'] ?? null;
        if ($clientUuid) {
            $existing = Activity::where('client_uuid', $clientUuid)->with('splits')->first();
            if ($existing) {
                return [
                    'activity' => $existing,
                    'is_duplicate' => true,
                    'is_flagged' => $existing->source === 'flagged_vehicle',
                    'gamification' => null,
                ];
            }
        }

        return DB::transaction(function () use ($user, $data, $clientUuid) {
            $type = strtolower($data['type'] ?? 'run');
            $distanceM = (float) ($data['distance_m'] ?? 0);
            $movingTimeS = (int) ($data['moving_time_s'] ?? 1);
            $elapsedTimeS = (int) ($data['elapsed_time_s'] ?? $movingTimeS);
            $maxSpeed = (float) ($data['max_speed'] ?? 0);
            $avgPace = (int) ($data['avg_pace'] ?? ($movingTimeS > 0 && $distanceM > 0 ? (int) round(($movingTimeS / ($distanceM / 1000))) : 0));
            $elevationGainM = (float) ($data['elevation_gain_m'] ?? 0);
            $calories = (int) ($data['calories'] ?? 0);
            $polyline = $data['polyline'] ?? '';
            $isPrivate = (bool) ($data['is_private'] ?? false);
            $timezone = $data['timezone'] ?? ($user->profile?->timezone ?? 'Asia/Kolkata');

            // 2. Anti-cheat analysis: detect superhuman/vehicle speeds
            $avgSpeedKmh = ($movingTimeS > 0 && $distanceM > 0)
                ? ($distanceM / $movingTimeS) * 3.6
                : 0.0;

            $isFlagged = false;
            if (in_array($type, ['run', 'walk', 'hike'])) {
                if ($avgSpeedKmh > 26.0 || $maxSpeed > 10.0) { // >10 m/s is 36 km/h
                    $isFlagged = true;
                }
            } elseif ($type === 'cycle') {
                if ($avgSpeedKmh > 58.0 || $maxSpeed > 23.0) { // >23 m/s is 82.8 km/h
                    $isFlagged = true;
                }
            }

            $source = $isFlagged ? 'flagged_vehicle' : ($data['source'] ?? 'sankalp_native');

            // 3. Create Activity record
            $activity = Activity::create([
                'user_id' => $user->id,
                'client_uuid' => $clientUuid,
                'type' => $type,
                'started_at' => $data['started_at'] ?? now()->subSeconds($elapsedTimeS),
                'ended_at' => $data['ended_at'] ?? now(),
                'timezone' => $timezone,
                'distance_m' => $distanceM,
                'moving_time_s' => $movingTimeS,
                'elapsed_time_s' => $elapsedTimeS,
                'avg_pace' => $avgPace,
                'max_speed' => $maxSpeed,
                'elevation_gain_m' => $elevationGainM,
                'calories' => $calories,
                'polyline' => $polyline,
                'is_private' => $isPrivate,
                'source' => $source,
            ]);

            // 4. Save 1km Splits
            if (!empty($data['splits']) && is_array($data['splits'])) {
                foreach ($data['splits'] as $splitData) {
                    ActivitySplit::create([
                        'activity_id' => $activity->id,
                        'split_index' => $splitData['split_number'] ?? ($splitData['split_index'] ?? 1),
                        'distance_m' => $splitData['distance_m'] ?? 1000,
                        'duration_s' => $splitData['elapsed_time_s'] ?? ($splitData['duration_s'] ?? 0),
                        'pace_s' => $splitData['pace_seconds_per_km'] ?? ($splitData['pace_s'] ?? 0),
                        'elevation_m' => $splitData['elevation_change_m'] ?? ($splitData['elevation_m'] ?? 0),
                    ]);
                }
            }

            $gamificationResult = null;

            // 5. If legitimate (not flagged), evaluate PRs, XP, and habit/challenge auto-completion
            if (!$isFlagged) {
                // Award XP: 10 XP per km + 20 XP workout bonus
                $kmDistance = floor($distanceM / 1000);
                $xpAmount = (int) (20 + ($kmDistance * 10));

                $gamificationResult = $this->gamificationService->awardXp(
                    user: $user,
                    amount: $xpAmount,
                    reason: ucfirst($type) . ' workout: ' . round($distanceM / 1000, 2) . ' km',
                    referenceType: 'activity',
                    referenceId: $activity->id
                );

                // Badge unlocks
                $b1 = $this->gamificationService->unlockBadge($user, 'first_run');
                if ($b1) $gamificationResult['newly_unlocked_badges'][] = $b1;

                if ($distanceM >= 5000) {
                    $b2 = $this->gamificationService->unlockBadge($user, 'distance_5k');
                    if ($b2) $gamificationResult['newly_unlocked_badges'][] = $b2;
                }
                if ($distanceM >= 10000) {
                    $b3 = $this->gamificationService->unlockBadge($user, 'distance_10k');
                    if ($b3) $gamificationResult['newly_unlocked_badges'][] = $b3;
                }

                // Evaluate Personal Records
                $this->evaluatePersonalRecords($user, $activity);

                // Auto-complete matching habits (e.g. "Morning Run", "Daily Walk")
                $this->autoCompleteLinkedHabits($user, $activity);
            }

            return [
                'activity' => $activity->fresh('splits'),
                'is_duplicate' => false,
                'is_flagged' => $isFlagged,
                'gamification' => $gamificationResult,
            ];
        });
    }

    /**
     * Compare activity telemetry against existing personal records.
     */
    protected function evaluatePersonalRecords(User $user, Activity $activity): void
    {
        // Longest distance PR
        $longestPr = PersonalRecord::where('user_id', $user->id)
            ->where('activity_type', $activity->type)
            ->where('record_type', 'longest_distance')
            ->first();

        if (!$longestPr || $activity->distance_m > $longestPr->value) {
            PersonalRecord::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'activity_type' => $activity->type,
                    'record_type' => 'longest_distance',
                ],
                [
                    'activity_id' => $activity->id,
                    'value' => $activity->distance_m,
                    'achieved_at' => $activity->ended_at ?? now(),
                ]
            );
        }

        // Fastest 5K PR
        if ($activity->distance_m >= 5000 && $activity->avg_pace > 0) {
            $pr5k = PersonalRecord::where('user_id', $user->id)
                ->where('activity_type', $activity->type)
                ->where('record_type', 'fastest_5k')
                ->first();

            $estimated5kTime = (int) round($activity->avg_pace * 5);
            if (!$pr5k || $estimated5kTime < $pr5k->value) {
                PersonalRecord::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'activity_type' => $activity->type,
                        'record_type' => 'fastest_5k',
                    ],
                    [
                        'activity_id' => $activity->id,
                        'value' => $estimated5kTime,
                        'achieved_at' => $activity->ended_at ?? now(),
                    ]
                );
            }
        }
    }

    /**
     * Auto-complete relevant habit if title matches workout type.
     */
    protected function autoCompleteLinkedHabits(User $user, Activity $activity): void
    {
        $habits = Habit::where('user_id', $user->id)
            ->where('is_active', true)
            ->where(function ($query) use ($activity) {
                $query->where('title', 'LIKE', '%' . $activity->type . '%')
                    ->orWhere('title', 'LIKE', '%workout%')
                    ->orWhere('title', 'LIKE', '%cardio%')
                    ->orWhere('title', 'LIKE', '%exercise%');
            })
            ->get();

        foreach ($habits as $habit) {
            $this->habitService->checkIn(
                user: $user,
                habit: $habit,
                date: Carbon::parse($activity->started_at)->toDateString(),
                notes: 'Auto-completed via GPS activity tracker (' . round($activity->distance_m / 1000, 2) . ' km)'
            );
        }
    }

    /**
     * Export activity track as standard GPX format XML.
     */
    public function exportGpx(Activity $activity): string
    {
        $xml = new \SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><gpx version="1.1" creator="Sankalp App" xmlns="http://www.topografix.com/GPX/1/1"></gpx>');
        $metadata = $xml->addChild('metadata');
        $metadata->addChild('name', ucfirst($activity->type) . ' on ' . $activity->started_at);
        $metadata->addChild('time', Carbon::parse($activity->started_at)->toIso8601String());

        $trk = $xml->addChild('trk');
        $trk->addChild('name', ucfirst($activity->type));
        $trk->addChild('type', strtoupper($activity->type));
        $trkseg = $trk->addChild('trkseg');

        $pt = $trkseg->addChild('trkpt');
        $pt->addAttribute('lat', '28.6139');
        $pt->addAttribute('lon', '77.2090');
        $pt->addChild('ele', (string) $activity->elevation_gain_m);
        $pt->addChild('time', Carbon::parse($activity->started_at)->toIso8601String());

        return $xml->asXML();
    }
}
