<?php

namespace App\Http\Requests\Device;

use Illuminate\Foundation\Http\FormRequest;

class RegisterDeviceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'device_uuid' => ['required', 'string', 'max:120'],
            'fcm_token' => ['nullable', 'string', 'max:500'],
            'platform' => ['required', 'string', 'in:android,ios,web'],
            'device_model' => ['nullable', 'string', 'max:100'],
            'os_version' => ['nullable', 'string', 'max:50'],
            'app_version' => ['nullable', 'string', 'max:50'],
            'timezone' => ['nullable', 'string', 'max:64'],
            'dnd_granted' => ['nullable', 'boolean'],
            'usage_stats_granted' => ['nullable', 'boolean'],
            'location_permission_status' => ['nullable', 'string', 'in:granted,denied,permanently_denied'],
        ];
    }
}
