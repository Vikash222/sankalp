<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UsageStatDaily extends Model
{
    use HasFactory;

    protected $table = 'usage_stats_daily';

    protected $fillable = [
        'user_id',
        'stat_date',
        'total_screen_time_seconds',
        'unlock_count',
        'pickups',
        'top_apps_json',
    ];

    protected function casts(): array
    {
        return [
            'stat_date' => 'date',
            'total_screen_time_seconds' => 'integer',
            'unlock_count' => 'integer',
            'pickups' => 'integer',
            'top_apps_json' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
