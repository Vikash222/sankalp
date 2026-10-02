<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ActivitySplit extends Model
{
    use HasFactory;

    protected $fillable = [
        'activity_id',
        'split_index',
        'distance_m',
        'duration_s',
        'pace_s',
        'elevation_m',
    ];

    protected function casts(): array
    {
        return [
            'split_index' => 'integer',
            'distance_m' => 'decimal:2',
            'duration_s' => 'integer',
            'pace_s' => 'integer',
            'elevation_m' => 'decimal:2',
        ];
    }

    public function activity(): BelongsTo
    {
        return $this->belongsTo(Activity::class);
    }
}
