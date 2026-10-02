<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Mood extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'mood_date',
        'score',
        'energy_level',
        'tags_json',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'mood_date' => 'date',
            'score' => 'integer',
            'energy_level' => 'integer',
            'tags_json' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
