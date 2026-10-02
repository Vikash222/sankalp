<?php

namespace App\Services\AI\Drivers;

use App\Services\AI\LlmProviderInterface;

class MockLlmDriver implements LlmProviderInterface
{
    public function __construct(protected array $config = []) {}

    public function generateResponse(array $messages, array $options = []): array
    {
        $lastUserMsg = '';
        foreach (array_reverse($messages) as $msg) {
            if ($msg['role'] === 'user') {
                $lastUserMsg = strtolower($msg['content']);
                break;
            }
        }

        if (str_contains($lastUserMsg, 'lazy') || str_contains($lastUserMsg, 'procrastinat') || str_contains($lastUserMsg, 'give up')) {
            $reply = "Remember your initial vow when you embarked on Sankalp. Action precedes motivation. Do not wait to feel ready; take a single 2-minute step immediately. Drink a glass of water, step away from your device, and execute your first task.";
        } elseif (str_contains($lastUserMsg, 'streak') || str_contains($lastUserMsg, 'freeze')) {
            $reply = "A streak is merely a reflection of your underlying commitment. If you missed a day, do not surrender to shame. Return to the arena immediately today. Consistency is rebuilt one repetition at a time.";
        } elseif (str_contains($lastUserMsg, 'run') || str_contains($lastUserMsg, 'exercise') || str_contains($lastUserMsg, 'workout')) {
            $reply = "Physical discipline strengthens neurological resolve. Put your running shoes on right now. Even a brisk 15-minute walk will break the state of lethargy and elevate your dopamine baseline naturally.";
        } else {
            $reply = "Discipline is the bridge between goals and accomplishment. Anchor your day with clarity, eliminate distractions, and focus on finishing the single most important task scheduled in your Sankalp roadmap today.";
        }

        return [
            'content' => $reply,
            'prompt_tokens' => 150,
            'completion_tokens' => 65,
            'model' => $this->config['model'] ?? 'mock-discipline-v1',
        ];
    }
}
