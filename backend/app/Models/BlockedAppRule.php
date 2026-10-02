<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BlockedAppRule extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'package_name',
        'app_name',
        'is_blocked',
        'daily_limit_minutes',
    ];

    protected function casts(): array
    {
        return [
            'is_blocked' => 'boolean',
            'daily_limit_minutes' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
