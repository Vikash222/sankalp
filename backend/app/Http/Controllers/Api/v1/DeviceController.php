<?php

namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Device\RegisterDeviceRequest;
use App\Http\Responses\ApiResponse;
use App\Models\Device;
use Illuminate\Http\JsonResponse;

class DeviceController extends Controller
{
    /**
     * Register or update mobile device telemetry and push tokens.
     */
    public function register(RegisterDeviceRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $device = Device::updateOrCreate(
            [
                'user_id' => $user->id,
                'device_uuid' => $validated['device_uuid'],
            ],
            array_merge($validated, ['last_active_at' => now()])
        );

        return ApiResponse::success(
            data: $device,
            message: 'Device registered successfully.'
        );
    }
}
