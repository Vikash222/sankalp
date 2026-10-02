<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Level extends Model
{
    use HasFactory;

    protected $fillable = [
        'level_number',
        'title',
        'title_hi',
        'min_xp',
    ];

    protected function casts(): array
    {
        return [
            'level_number' => 'integer',
            'min_xp' => 'integer',
        ];
    }
}
