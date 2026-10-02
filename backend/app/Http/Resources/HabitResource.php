<?php

namespace App\Http\Resources;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HabitResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $timezone = $request->user()?->profile?->timezone ?? 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();

        $todayLog = $this->logs()->where('log_date', $today)->first();
        $streak = $this->streak;

        return [
            'id' => $this->id,
            'title' => $this->title,
            'title_hi' => $this->title_hi,
            'description' => $this->description,
            'category' => $this->category,
            'cadence' => $this->cadence,
            'target_value' => $this->target_value,
            'unit' => $this->unit,
            'reminder_time' => $this->reminder_time,
            'is_active' => (bool) $this->is_active,
            'is_completed_today' => $todayLog !== null && (bool) $todayLog->is_completed,
            'current_streak' => $streak ? $streak->current_streak : 0,
            'longest_streak' => $streak ? $streak->longest_streak : 0,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
