<?php

namespace App\Http\Requests\Detox;

use Illuminate\Foundation\Http\FormRequest;

class StoreFocusSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'duration_minutes' => ['required', 'integer', 'min:1', 'max:720'],
            'completed_minutes' => ['nullable', 'integer', 'min:0', 'max:720'],
            'mode' => ['required', 'string', 'in:deep_work,study,pomodoro,digital_detox,meditation'],
            'is_successful' => ['nullable', 'boolean'],
            'started_at' => ['nullable', 'date'],
            'ended_at' => ['nullable', 'date'],
            'interruption_count' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
