<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserChallengeTask extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_challenge_id',
        'user_id',
        'day_number',
        'task_title',
        'task_title_hi',
        'is_completed',
        'completed_at',
        'xp_awarded',
    ];

    protected function casts(): array
    {
        return [
            'day_number' => 'integer',
            'is_completed' => 'boolean',
            'completed_at' => 'datetime',
            'xp_awarded' => 'integer',
        ];
    }

    public function userChallenge(): BelongsTo
    {
        return $this->belongsTo(UserChallenge::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
