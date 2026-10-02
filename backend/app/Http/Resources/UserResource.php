<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'name' => $this->name ?? 'Sankalp Practitioner',
            'email' => $this->email,
            'is_guest' => (bool) $this->is_guest,
            'email_verified' => $this->email_verified_at !== null,
            'profile' => new UserProfileResource($this->whenLoaded('profile')),
            'total_xp' => $this->total_xp,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
