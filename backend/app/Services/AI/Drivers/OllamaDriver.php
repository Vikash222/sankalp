<?php

namespace App\Services\AI\Drivers;

use App\Services\AI\LlmProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class OllamaDriver implements LlmProviderInterface
{
    public function __construct(protected array $config) {}

    public function generateResponse(array $messages, array $options = []): array
    {
        $baseUrl = rtrim($this->config['base_url'] ?? 'http://127.0.0.1:11434', '/');
        $model = $options['model'] ?? ($this->config['model'] ?? 'llama3.2:3b');
        $temperature = $options['temperature'] ?? ($this->config['temperature'] ?? 0.7);

        $response = Http::timeout(60)
            ->post("{$baseUrl}/api/chat", [
                'model' => $model,
                'messages' => $messages,
                'stream' => false,
                'options' => [
                    'temperature' => $temperature,
                ],
            ]);

        if ($response->failed()) {
            throw new RuntimeException('Ollama service error: ' . $response->body());
        }

        $json = $response->json();
        $content = $json['message']['content'] ?? '';
        $promptEvalCount = (int) ($json['prompt_eval_count'] ?? 0);
        $evalCount = (int) ($json['eval_count'] ?? 0);

        return [
            'content' => trim($content),
            'prompt_tokens' => $promptEvalCount,
            'completion_tokens' => $evalCount,
            'model' => $model,
        ];
    }
}
