<?php

namespace App\Http\Requests\Detox;

use Illuminate\Foundation\Http\FormRequest;

class StoreBlockedAppRuleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'package_name' => ['required', 'string', 'max:128'],
            'app_name' => ['required', 'string', 'max:100'],
            'is_blocked' => ['nullable', 'boolean'],
            'daily_limit_minutes' => ['nullable', 'integer', 'min:0', 'max:1440'],
        ];
    }
}
