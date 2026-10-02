<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Detox\SyncUsageStatsRequest;
use App\Http\Responses\ApiResponse;
use App\Models\UsageStatDaily;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UsageStatsController extends Controller
{
    /**
     * Ingest daily application usage statistics from Android UsageStatsManager.
     */
    public function sync(SyncUsageStatsRequest $request): JsonResponse
    {
        $user = $request->user();
        $stats = $request->validated('stats');

        $count = 0;
        foreach ($stats as $item) {
            UsageStatDaily::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'stat_date' => $item['stat_date'],
                    'package_name' => $item['package_name'],
                ],
                [
                    'app_name' => $item['app_name'] ?? $item['package_name'],
                    'screen_time_minutes' => $item['screen_time_minutes'],
                    'unlocks_count' => $item['unlocks_count'] ?? 0,
                ]
            );
            $count++;
        }

        return ApiResponse::success(
            data: ['synced_records' => $count],
            message: 'Device usage telemetry synchronized successfully.'
        );
    }

    /**
     * Retrieve aggregated usage telemetry for the day or week.
     */
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();

        $todayStats = UsageStatDaily::where('user_id', $user->id)
            ->where('stat_date', $today)
            ->orderByDesc('screen_time_minutes')
            ->get();

        $totalMinutes = $todayStats->sum('screen_time_minutes');
        $targetMinutes = $user->profile?->screen_time_target_min ?? 120;

        return ApiResponse::success(
            data: [
                'date' => $today,
                'total_screen_time_minutes' => $totalMinutes,
                'target_minutes' => $targetMinutes,
                'is_under_target' => $totalMinutes <= $targetMinutes,
                'apps' => $todayStats,
            ],
            message: 'Daily usage summary retrieved.'
        );
    }
}
