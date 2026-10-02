<?php

namespace App\Services\AI\Drivers;

use App\Services\AI\LlmProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class GroqOpenRouterDriver implements LlmProviderInterface
{
    public function __construct(protected array $config) {}

    public function generateResponse(array $messages, array $options = []): array
    {
        $apiKey = $this->config['api_key'] ?? '';
        $baseUrl = rtrim($this->config['base_url'] ?? 'https://api.groq.com/openai/v1', '/');
        $model = $options['model'] ?? ($this->config['model'] ?? 'llama-3.3-70b-versatile');
        $temperature = $options['temperature'] ?? ($this->config['temperature'] ?? 0.7);
        $maxTokens = $options['max_tokens'] ?? ($this->config['max_tokens'] ?? 1024);

        if (empty($apiKey)) {
            // Graceful fallback to mock in case API key is unconfigured in development
            return (new MockLlmDriver($this->config))->generateResponse($messages, $options);
        }

        $response = Http::withToken($apiKey)
            ->timeout(30)
            ->post("{$baseUrl}/chat/completions", [
                'model' => $model,
                'messages' => $messages,
                'temperature' => $temperature,
                'max_tokens' => $maxTokens,
            ]);

        if ($response->failed()) {
            throw new RuntimeException('AI service communication failed: ' . $response->body());
        }

        $json = $response->json();
        $content = $json['choices'][0]['message']['content'] ?? '';
        $usage = $json['usage'] ?? [];

        return [
            'content' => trim($content),
            'prompt_tokens' => (int) ($usage['prompt_tokens'] ?? 0),
            'completion_tokens' => (int) ($usage['completion_tokens'] ?? 0),
            'model' => $model,
        ];
    }
}
