<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Activity extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'client_uuid',
        'type',
        'started_at',
        'ended_at',
        'timezone',
        'distance_m',
        'moving_time_s',
        'elapsed_time_s',
        'avg_pace',
        'max_speed',
        'elevation_gain_m',
        'calories',
        'polyline',
        'is_private',
        'source',
    ];

    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
            'distance_m' => 'decimal:2',
            'moving_time_s' => 'integer',
            'elapsed_time_s' => 'integer',
            'avg_pace' => 'integer',
            'max_speed' => 'decimal:2',
            'elevation_gain_m' => 'decimal:2',
            'calories' => 'integer',
            'is_private' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function splits(): HasMany
    {
        return $this->hasMany(ActivitySplit::class)->orderBy('split_index');
    }
}
