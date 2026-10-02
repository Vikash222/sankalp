<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Streak extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'habit_id',
        'current_streak',
        'longest_streak',
        'last_completed_date',
        'freeze_count',
    ];

    protected function casts(): array
    {
        return [
            'current_streak' => 'integer',
            'longest_streak' => 'integer',
            'last_completed_date' => 'date',
            'freeze_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function habit(): BelongsTo
    {
        return $this->belongsTo(Habit::class);
    }

    public function freezes(): HasMany
    {
        return $this->hasMany(StreakFreeze::class);
    }
}
