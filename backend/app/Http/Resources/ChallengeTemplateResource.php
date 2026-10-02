<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChallengeTemplateResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'title' => $this->title,
            'title_hi' => $this->title_hi,
            'description' => $this->description,
            'description_hi' => $this->description_hi,
            'category' => $this->category,
            'difficulty' => $this->difficulty,
            'duration_days' => $this->duration_days,
            'is_active' => (bool) $this->is_active,
            'total_tasks_count' => $this->tasks()->count(),
            'tasks' => $this->whenLoaded('tasks'),
        ];
    }
}
