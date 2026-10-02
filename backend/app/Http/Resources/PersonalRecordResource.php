<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PersonalRecordResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'activity_type' => $this->activity_type,
            'record_type' => $this->record_type,
            'value' => (float) $this->value,
            'activity_id' => $this->activity_id,
            'achieved_at' => $this->achieved_at?->toIso8601String(),
        ];
    }
}
