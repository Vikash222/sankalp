<?php

namespace App\Http\Requests\Challenge;

use Illuminate\Foundation\Http\FormRequest;

class StartChallengeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'template_id' => ['required', 'integer', 'exists:challenge_templates,id'],
            'start_date' => ['nullable', 'date'],
            'custom_title' => ['nullable', 'string', 'max:120'],
        ];
    }
}
