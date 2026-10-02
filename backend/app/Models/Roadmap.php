<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Roadmap extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'quiz_attempt_id',
        'title',
        'tier',
        'target_challenge_slug',
        'status',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function quizAttempt(): BelongsTo
    {
        return $this->belongsTo(QuizAttempt::class);
    }

    public function phases(): HasMany
    {
        return $this->hasMany(RoadmapPhase::class)->orderBy('phase_number');
    }
}
