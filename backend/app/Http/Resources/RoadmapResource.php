<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoadmapResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'tier' => $this->tier,
            'target_challenge_slug' => $this->target_challenge_slug,
            'status' => $this->status,
            'is_active' => $this->status === 'active',
            'phases' => $this->phases->map(fn ($p) => [
                'id' => $p->id,
                'phase_number' => $p->phase_number,
                'title' => $p->title,
                'focus' => $p->focus,
                'duration_days' => $p->duration_days,
                'is_unlocked' => (bool) $p->is_unlocked,
            ]),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
