<?php

namespace App\Services\AI;

use App\Services\AI\Drivers\GroqOpenRouterDriver;
use App\Services\AI\Drivers\HuggingFaceDriver;
use App\Services\AI\Drivers\MockLlmDriver;
use App\Services\AI\Drivers\OllamaDriver;
use InvalidArgumentException;

class LlmManager
{
    /**
     * Resolve the configured LLM provider driver instance.
     */
    public function driver(?string $name = null): LlmProviderInterface
    {
        $driverName = $name ?? config('ai.default', 'mock');
        $config = config("ai.providers.{$driverName}", []);

        return match ($driverName) {
            'mock' => new MockLlmDriver($config),
            'groq', 'openrouter' => new GroqOpenRouterDriver($config),
            'ollama' => new OllamaDriver($config),
            'huggingface' => new HuggingFaceDriver($config),
            default => throw new InvalidArgumentException("Unsupported AI provider driver: [{$driverName}]"),
        };
    }
}
