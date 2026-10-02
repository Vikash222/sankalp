<?php

namespace App\Http\Requests\Habit;

use Illuminate\Foundation\Http\FormRequest;

class CreateHabitRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:120'],
            'title_hi' => ['nullable', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
            'category' => ['required', 'string', 'max:50'],
            'cadence' => ['nullable', 'string', 'in:daily,weekdays,weekly'],
            'target_value' => ['nullable', 'integer', 'min:1'],
            'unit' => ['nullable', 'string', 'max:30'],
            'reminder_time' => ['nullable', 'string'],
        ];
    }
}
