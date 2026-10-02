<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QuizQuestion extends Model
{
    use HasFactory;

    protected $fillable = [
        'dimension',
        'order_number',
        'question_en',
        'question_hi',
    ];

    protected function casts(): array
    {
        return [
            'order_number' => 'integer',
        ];
    }

    public function options(): HasMany
    {
        return $this->hasMany(QuizOption::class)->orderBy('score_points');
    }
}
