<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FocusSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'duration_minutes' => $this->duration_minutes,
            'completed_minutes' => $this->completed_minutes,
            'mode' => $this->mode,
            'is_successful' => (bool) $this->is_successful,
            'started_at' => $this->started_at?->toIso8601String(),
            'ended_at' => $this->ended_at?->toIso8601String(),
            'interruption_count' => $this->interruption_count,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
