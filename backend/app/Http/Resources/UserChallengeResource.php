<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserChallengeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $total = $this->tasks()->count();
        $completed = $this->tasks()->where('is_completed', true)->count();
        $progressPct = $total > 0 ? round(($completed / $total) * 100, 1) : 0.0;

        return [
            'id' => $this->id,
            'challenge_template_id' => $this->challenge_template_id,
            'status' => $this->status,
            'started_at' => $this->started_at ? $this->started_at->toDateString() : null,
            'completed_at' => $this->completed_at ? $this->completed_at->toDateString() : null,
            'current_day' => $this->current_day,
            'is_comeback_mode' => (bool) $this->is_comeback_mode,
            'total_tasks' => $total,
            'completed_tasks' => $completed,
            'progress_percentage' => $progressPct,
            'template' => new ChallengeTemplateResource($this->whenLoaded('template')),
            'tasks' => UserChallengeTaskResource::collection($this->whenLoaded('tasks')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
