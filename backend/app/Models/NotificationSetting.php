<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'morning_enabled',
        'morning_time',
        'midday_enabled',
        'midday_time',
        'evening_enabled',
        'evening_time',
        'streak_risk_enabled',
        'comeback_enabled',
        'sound_enabled',
    ];

    protected function casts(): array
    {
        return [
            'morning_enabled' => 'boolean',
            'midday_enabled' => 'boolean',
            'evening_enabled' => 'boolean',
            'streak_risk_enabled' => 'boolean',
            'comeback_enabled' => 'boolean',
            'sound_enabled' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
