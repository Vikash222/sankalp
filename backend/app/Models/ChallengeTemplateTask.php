<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChallengeTemplateTask extends Model
{
    use HasFactory;

    protected $fillable = [
        'challenge_template_id',
        'day_number',
        'title',
        'title_hi',
        'description',
        'description_hi',
        'task_type',
        'target_value',
        'is_recovery_day',
        'xp_reward',
    ];

    protected function casts(): array
    {
        return [
            'day_number' => 'integer',
            'target_value' => 'integer',
            'is_recovery_day' => 'boolean',
            'xp_reward' => 'integer',
        ];
    }

    public function template(): BelongsTo
    {
        return $this->belongsTo(ChallengeTemplate::class, 'challenge_template_id');
    }
}
