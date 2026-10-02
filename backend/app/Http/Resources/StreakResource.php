<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StreakResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'scope' => $this->habit_id ? 'habit' : 'overall',
            'habit_id' => $this->habit_id,
            'current_streak' => $this->current_streak,
            'longest_streak' => $this->longest_streak,
            'last_completed_date' => $this->last_completed_date ? $this->last_completed_date->toDateString() : null,
            'freeze_count' => $this->freeze_count,
            'in_comeback_mode' => (bool) $this->in_comeback_mode,
        ];
    }
}
