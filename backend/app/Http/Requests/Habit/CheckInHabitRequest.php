<?php

namespace App\Http\Requests\Habit;

use Illuminate\Foundation\Http\FormRequest;

class CheckInHabitRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'date' => ['nullable', 'date'],
            'notes' => ['nullable', 'string', 'max:500'],
            'numeric_value' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
