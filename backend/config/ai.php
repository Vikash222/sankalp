<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Default AI Provider Driver
    |--------------------------------------------------------------------------
    |
    | Supported: "groq", "openrouter", "ollama", "huggingface", "mock"
    |
    */
    'default' => env('AI_PROVIDER', 'mock'),

    /*
    |--------------------------------------------------------------------------
    | Provider Configurations
    |--------------------------------------------------------------------------
    |
    | In compliance with project guidelines, all LLMs are strictly open-source
    | (Llama 3.x, Qwen 2.5, Gemma 2, Mistral) served via privacy-friendly
    | inference endpoints or local instances.
    |
    */
    'providers' => [
        'mock' => [
            'model' => 'mock-discipline-v1',
        ],

        'groq' => [
            'api_key' => env('GROQ_API_KEY'),
            'base_url' => env('GROQ_BASE_URL', 'https://api.groq.com/openai/v1'),
            'model' => env('GROQ_MODEL', 'llama-3.3-70b-versatile'),
            'temperature' => (float) env('AI_TEMPERATURE', 0.7),
            'max_tokens' => (int) env('AI_MAX_TOKENS', 1024),
        ],

        'openrouter' => [
            'api_key' => env('OPENROUTER_API_KEY'),
            'base_url' => env('OPENROUTER_BASE_URL', 'https://openrouter.ai/api/v1'),
            'model' => env('OPENROUTER_MODEL', 'meta-llama/llama-3.3-70b-instruct:free'),
            'temperature' => (float) env('AI_TEMPERATURE', 0.7),
            'max_tokens' => (int) env('AI_MAX_TOKENS', 1024),
        ],

        'ollama' => [
            'base_url' => env('OLLAMA_BASE_URL', 'http://127.0.0.1:11434'),
            'model' => env('OLLAMA_MODEL', 'llama3.2:3b'),
            'temperature' => (float) env('AI_TEMPERATURE', 0.7),
        ],

        'huggingface' => [
            'api_key' => env('HF_API_KEY'),
            'base_url' => env('HF_BASE_URL', 'https://api-inference.huggingface.co/models'),
            'model' => env('HF_MODEL', 'meta-llama/Meta-Llama-3-8B-Instruct'),
            'temperature' => (float) env('AI_TEMPERATURE', 0.7),
            'max_tokens' => (int) env('AI_MAX_TOKENS', 1024),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Sankalp Discipline Coach System Prompt
    |--------------------------------------------------------------------------
    */
    'system_prompt' => <<<PROMPT
You are Sankalp Discipline Coach — an empathetic, stoic, evidence-based habit and lifestyle mentor.
Your purpose is to help people conquer procrastination, overcome digital and screen addiction, establish unbreakable routines, and achieve physical and mental vitality.

Guidelines for coaching:
1. Always communicate in formal, grammatically impeccable English with an encouraging and firm tone.
2. Ground advice in behavioral science (habit stacking, implementation intentions, dopamine baseline management).
3. Be direct, compassionate, and actionable. Never shame or judge the user for relapses; guide them back onto the path immediately.
4. Keep responses concise (under 250 words) unless the user specifically asks for an in-depth breakdown.
5. Incorporate the user's specific context (current streak, active challenges, daily tasks) when provided.
PROMPT,
];
