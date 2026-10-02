<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StreakFreeze extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'streak_id',
        'used_for_date',
        'status',
        'earned_at',
        'used_at',
    ];

    protected function casts(): array
    {
        return [
            'used_for_date' => 'date',
            'earned_at' => 'datetime',
            'used_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function streak(): BelongsTo
    {
        return $this->belongsTo(Streak::class);
    }
}
