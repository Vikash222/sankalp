<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'bio' => $this->bio,
            'avatar_url' => $this->avatar_url,
            'weight_kg' => (float) $this->weight_kg,
            'height_cm' => (float) $this->height_cm,
            'language' => $this->language ?? 'en',
            'theme' => $this->theme ?? 'day',
            'timezone' => $this->timezone ?? 'Asia/Kolkata',
            'daily_water_target_ml' => $this->daily_water_target_ml ?? 3000,
            'screen_time_target_min' => $this->screen_time_target_min ?? 120,
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
