<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BadgeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'tier' => $this->tier,
            'icon_name' => $this->icon_name,
            'xp_bonus' => $this->xp_bonus,
            'is_unlocked' => $this->pivot ? true : false,
            'unlocked_at' => $this->pivot?->unlocked_at,
        ];
    }
}
