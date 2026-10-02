<?php

namespace App\Http\Requests\Detox;

use Illuminate\Foundation\Http\FormRequest;

class SyncUsageStatsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'stats' => ['required', 'array', 'min:1'],
            'stats.*.stat_date' => ['required', 'date'],
            'stats.*.package_name' => ['required', 'string', 'max:191'],
            'stats.*.app_name' => ['nullable', 'string', 'max:120'],
            'stats.*.screen_time_minutes' => ['required', 'integer', 'min:0'],
            'stats.*.unlocks_count' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
