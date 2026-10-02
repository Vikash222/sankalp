<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FocusSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'duration_minutes',
        'completed_minutes',
        'mode',
        'is_successful',
        'started_at',
        'ended_at',
        'interruption_count',
    ];

    protected function casts(): array
    {
        return [
            'duration_minutes' => 'integer',
            'completed_minutes' => 'integer',
            'is_successful' => 'boolean',
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'interruption_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
