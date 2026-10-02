<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Badge extends Model
{
    use HasFactory;

    protected $fillable = [
        'slug',
        'title',
        'title_hi',
        'description',
        'description_hi',
        'tier',
        'icon',
        'unlock_criteria_json',
    ];

    protected function casts(): array
    {
        return [
            'unlock_criteria_json' => 'array',
        ];
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_badges')
            ->withPivot('unlocked_at')
            ->withTimestamps();
    }
}
