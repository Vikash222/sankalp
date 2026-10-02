<?php

namespace App\Http\Responses;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\JsonResponse;

class ApiResponse
{
    /**
     * Generate a standardized success response.
     */
    public static function success(
        mixed $data = null,
        string $message = 'Operation completed successfully.',
        int $statusCode = 200,
        array $meta = []
    ): JsonResponse {
        $payload = [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ];

        if (!empty($meta)) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $statusCode);
    }

    /**
     * Generate a standardized error response.
     */
    public static function error(
        string $message,
        string $errorCode = 'BAD_REQUEST',
        int $statusCode = 400,
        mixed $details = null
    ): JsonResponse {
        $errorPayload = [
            'code' => $errorCode,
            'message' => $message,
        ];

        if ($details !== null) {
            $errorPayload['details'] = $details;
        }

        return response()->json([
            'success' => false,
            'error' => $errorPayload,
        ], $statusCode);
    }

    /**
     * Generate a standardized paginated response.
     */
    public static function paginated(
        LengthAwarePaginator $paginator,
        ?string $resourceClass = null,
        string $message = 'Records retrieved successfully.'
    ): JsonResponse {
        $items = $paginator->items();

        if ($resourceClass !== null && class_exists($resourceClass)) {
            $items = $resourceClass::collection($items);
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $items,
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'has_more_pages' => $paginator->hasMorePages(),
            ],
        ], 200);
    }
}
