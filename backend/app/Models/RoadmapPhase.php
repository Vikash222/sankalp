<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RoadmapPhase extends Model
{
    use HasFactory;

    protected $fillable = [
        'roadmap_id',
        'phase_number',
        'title',
        'focus',
        'duration_days',
        'is_unlocked',
    ];

    protected function casts(): array
    {
        return [
            'phase_number' => 'integer',
            'duration_days' => 'integer',
            'is_unlocked' => 'boolean',
        ];
    }

    public function roadmap(): BelongsTo
    {
        return $this->belongsTo(Roadmap::class);
    }
}
