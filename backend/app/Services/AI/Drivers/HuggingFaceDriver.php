<?php

namespace App\Services\AI\Drivers;

use App\Services\AI\LlmProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class HuggingFaceDriver implements LlmProviderInterface
{
    public function __construct(protected array $config) {}

    public function generateResponse(array $messages, array $options = []): array
    {
        $apiKey = $this->config['api_key'] ?? '';
        $model = $options['model'] ?? ($this->config['model'] ?? 'meta-llama/Meta-Llama-3-8B-Instruct');
        $baseUrl = rtrim($this->config['base_url'] ?? 'https://api-inference.huggingface.co/models', '/');
        $endpoint = "{$baseUrl}/{$model}/v1/chat/completions";

        if (empty($apiKey)) {
            return (new MockLlmDriver($this->config))->generateResponse($messages, $options);
        }

        $response = Http::withToken($apiKey)
            ->timeout(45)
            ->post($endpoint, [
                'model' => $model,
                'messages' => $messages,
                'temperature' => $options['temperature'] ?? ($this->config['temperature'] ?? 0.7),
                'max_tokens' => $options['max_tokens'] ?? ($this->config['max_tokens'] ?? 1024),
            ]);

        if ($response->failed()) {
            throw new RuntimeException('HuggingFace inference API error: ' . $response->body());
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
