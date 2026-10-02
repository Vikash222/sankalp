<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HabitLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'habit_id',
        'user_id',
        'log_date',
        'is_completed',
        'logged_value',
        'note',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'log_date' => 'date',
            'is_completed' => 'boolean',
            'logged_value' => 'integer',
            'completed_at' => 'datetime',
        ];
    }

    public function habit(): BelongsTo
    {
        return $this->belongsTo(Habit::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
