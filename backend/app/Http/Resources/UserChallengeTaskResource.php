<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserChallengeTaskResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_challenge_id' => $this->user_challenge_id,
            'day_number' => $this->day_number,
            'task_title' => $this->task_title,
            'task_title_hi' => $this->task_title_hi,
            'is_completed' => (bool) $this->is_completed,
            'completed_at' => $this->completed_at?->toIso8601String(),
            'xp_awarded' => $this->xp_awarded,
        ];
    }
}
