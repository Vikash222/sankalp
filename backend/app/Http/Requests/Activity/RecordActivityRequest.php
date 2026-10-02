<?php

namespace App\Http\Requests\Activity;

use Illuminate\Foundation\Http\FormRequest;

class RecordActivityRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    protected function prepareForValidation(): void
    {
        $merge = [];
        if ($this->has('distance_meters') && !$this->has('distance_m')) {
            $merge['distance_m'] = $this->input('distance_meters');
        }
        if ($this->has('moving_time_seconds') && !$this->has('moving_time_s')) {
            $merge['moving_time_s'] = $this->input('moving_time_seconds');
        }
        if ($this->has('elapsed_time_seconds') && !$this->has('elapsed_time_s')) {
            $merge['elapsed_time_s'] = $this->input('elapsed_time_seconds');
        }
        if ($this->has('avg_pace_seconds_per_km') && !$this->has('avg_pace')) {
            $merge['avg_pace'] = $this->input('avg_pace_seconds_per_km');
        }
        if ($this->has('max_speed_mps') && !$this->has('max_speed')) {
            $merge['max_speed'] = $this->input('max_speed_mps');
        }
        if ($this->has('elevation_gain_meters') && !$this->has('elevation_gain_m')) {
            $merge['elevation_gain_m'] = $this->input('elevation_gain_meters');
        }
        if ($this->has('splits') && is_array($this->input('splits'))) {
            $normalizedSplits = [];
            foreach ($this->input('splits') as $split) {
                if (is_array($split)) {
                    $normalizedSplits[] = [
                        'split_number' => $split['split_number'] ?? $split['split_index'] ?? 1,
                        'distance_m' => $split['distance_m'] ?? $split['distance_meters'] ?? 1000.0,
                        'elapsed_time_s' => $split['elapsed_time_s'] ?? $split['duration_seconds'] ?? 0,
                        'pace_seconds_per_km' => $split['pace_seconds_per_km'] ?? 0,
                        'elevation_change_m' => $split['elevation_change_m'] ?? $split['elevation_change_meters'] ?? 0.0,
                    ];
                }
            }
            $merge['splits'] = $normalizedSplits;
        }
        if (!empty($merge)) {
            $this->merge($merge);
        }
    }

    public function rules(): array
    {
        return [
            'client_uuid' => ['required', 'string', 'max:120'],
            'type' => ['required', 'string', 'in:run,walk,cycle,hike'],
            'started_at' => ['required', 'date'],
            'ended_at' => ['required', 'date', 'after:started_at'],
            'distance_m' => ['required', 'numeric', 'min:0'],
            'moving_time_s' => ['required', 'integer', 'min:1'],
            'elapsed_time_s' => ['nullable', 'integer', 'min:1'],
            'avg_pace' => ['nullable', 'integer', 'min:0'],
            'max_speed' => ['nullable', 'numeric', 'min:0'],
            'elevation_gain_m' => ['nullable', 'numeric'],
            'calories' => ['nullable', 'integer', 'min:0'],
            'polyline' => ['nullable', 'string'],
            'is_private' => ['nullable', 'boolean'],
            'timezone' => ['nullable', 'string', 'max:64'],
            'source' => ['nullable', 'string', 'max:50'],
            'splits' => ['nullable', 'array'],
            'splits.*.split_number' => ['required', 'integer'],
            'splits.*.distance_m' => ['required', 'numeric'],
            'splits.*.elapsed_time_s' => ['required', 'integer'],
            'splits.*.pace_seconds_per_km' => ['required', 'integer'],
            'splits.*.elevation_change_m' => ['nullable', 'numeric'],
        ];
    }
}
