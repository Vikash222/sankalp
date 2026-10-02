<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class UserProfile extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'avatar_url',
        'bio',
        'weight_kg',
        'height_cm',
        'birth_date',
        'wake_time',
        'sleep_time',
        'daily_water_target_ml',
        'screen_time_target_min',
        'language',
        'theme',
        'timezone',
    ];

    protected function casts(): array
    {
        return [
            'weight_kg' => 'decimal:2',
            'height_cm' => 'decimal:2',
            'birth_date' => 'date',
            'daily_water_target_ml' => 'integer',
            'screen_time_target_min' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
