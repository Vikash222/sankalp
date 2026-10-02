<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ActivityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'client_uuid' => $this->client_uuid,
            'type' => $this->type,
            'started_at' => $this->started_at?->toIso8601String(),
            'ended_at' => $this->ended_at?->toIso8601String(),
            'distance_m' => (float) $this->distance_m,
            'moving_time_s' => (int) $this->moving_time_s,
            'elapsed_time_s' => (int) $this->elapsed_time_s,
            'avg_pace' => (int) $this->avg_pace,
            'max_speed' => (float) $this->max_speed,
            'elevation_gain_m' => (float) $this->elevation_gain_m,
            'calories' => (int) $this->calories,
            'polyline' => $this->polyline,
            'is_private' => (bool) $this->is_private,
            'source' => $this->source,
            'is_flagged' => $this->source === 'flagged_vehicle',
            'splits' => $this->splits->map(fn ($s) => [
                'split_index' => $s->split_index,
                'distance_m' => (float) $s->distance_m,
                'duration_s' => (int) $s->duration_s,
                'pace_s' => (int) $s->pace_s,
                'elevation_m' => (float) $s->elevation_m,
            ]),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
