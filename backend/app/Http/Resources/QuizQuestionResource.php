<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QuizQuestionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'dimension' => $this->dimension,
            'order_number' => $this->order_number,
            'question_en' => $this->question_en,
            'question_hi' => $this->question_hi,
            'options' => $this->options->map(fn ($opt) => [
                'id' => $opt->id,
                'score_points' => $opt->score_points,
                'option_en' => $opt->option_en,
                'option_hi' => $opt->option_hi,
            ]),
        ];
    }
}
