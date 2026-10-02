<?php

namespace App\Http\Requests\User;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'name' => ['nullable', 'string', 'max:120'],
            'bio' => ['nullable', 'string', 'max:500'],
            'avatar_url' => ['nullable', 'string', 'url', 'max:255'],
            'weight_kg' => ['nullable', 'numeric', 'min:20', 'max:300'],
            'height_cm' => ['nullable', 'numeric', 'min:80', 'max:260'],
            'language' => ['nullable', 'string', 'in:en,hi'],
            'theme' => ['nullable', 'string', 'in:day,dark,night,custom'],
            'timezone' => ['nullable', 'string', 'max:64'],
            'daily_water_target_ml' => ['nullable', 'integer', 'min:500', 'max:10000'],
            'screen_time_target_min' => ['nullable', 'integer', 'min:10', 'max:1440'],
        ];
    }
}
