<?php

namespace App\Services\AI;

interface LlmProviderInterface
{
    /**
     * Generate completion response from an open-source LLM.
     *
     * @param array<int, array{role: string, content: string}> $messages
     * @param array<string, mixed> $options
     * @return array{content: string, prompt_tokens: int, completion_tokens: int, model: string}
     */
    public function generateResponse(array $messages, array $options = []): array;
}
