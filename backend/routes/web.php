<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

Route::get('/', function (Request $request) {
    if ($request->wantsJson() || $request->is('api/*')) {
        return response()->json([
            'app' => config('app.name', 'Sankalp'),
            'status' => 'online',
            'version' => '1.0.0',
            'endpoints' => [
                'health' => '/health',
                'api' => '/api/v1',
            ],
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    return response('<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sankalp API Server</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .card { background: #1e293b; border-radius: 16px; padding: 40px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; max-width: 480px; width: 90%; border: 1px solid #334155; }
        .badge { background: #10b981; color: #022c22; font-weight: 700; padding: 4px 12px; border-radius: 9999px; font-size: 13px; display: inline-block; margin-bottom: 16px; }
        h1 { margin: 0 0 10px; font-size: 26px; }
        p { color: #94a3b8; line-height: 1.6; margin: 0 0 24px; font-size: 15px; }
        .meta { background: #0f172a; border-radius: 8px; padding: 12px; font-size: 13px; color: #cbd5e1; text-align: left; font-family: monospace; }
        .meta div { margin-bottom: 4px; }
        .meta div:last-child { margin-bottom: 0; }
    </style>
</head>
<body>
    <div class="card">
        <span class="badge">&#9679; ONLINE</span>
        <h1>Sankalp API Backend</h1>
        <p>The backend service for Sankalp Habit & Digital Detox platform is up and running smoothly.</p>
        <div class="meta">
            <div><strong>Status:</strong> 200 OK (Healthy)</div>
            <div><strong>Version:</strong> 1.0.0</div>
            <div><strong>API Base:</strong> /api/v1</div>
        </div>
    </div>
</body>
</html>', 200)->header('Content-Type', 'text/html; charset=utf-8');
});

Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::get('/privacy', function () {
    $privacyFile = public_path('privacy.html');
    if (file_exists($privacyFile)) {
        return response()->file($privacyFile, ['Content-Type' => 'text/html; charset=utf-8']);
    }
    return redirect('https://github.com/Vikash222/sankalp/blob/main/PRIVACY_POLICY.md');
});

