<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class UserChallenge extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'challenge_template_id',
        'started_at',
        'completed_at',
        'status',
        'current_day',
        'is_comeback_mode',
        'comeback_expires_at',
    ];

    protected function casts(): array
    {
        return [
            'started_at' => 'date',
            'completed_at' => 'date',
            'current_day' => 'integer',
            'is_comeback_mode' => 'boolean',
            'comeback_expires_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function template(): BelongsTo
    {
        return $this->belongsTo(ChallengeTemplate::class, 'challenge_template_id');
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(UserChallengeTask::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
}
