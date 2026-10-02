<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BlockedAppRuleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'package_name' => $this->package_name,
            'app_name' => $this->app_name,
            'is_blocked' => (bool) $this->is_blocked,
            'daily_limit_minutes' => $this->daily_limit_minutes,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
