<?php

namespace App\Services\AI;

use App\Models\AiConversation;
use App\Models\AiMessage;
use App\Models\AiUsageLog;
use App\Models\HabitLog;
use App\Models\Streak;
use App\Models\User;
use App\Models\UserChallenge;
use App\Models\UserChallengeTask;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AiCoachService
{
    public function __construct(protected LlmManager $llmManager) {}

    /**
     * Send message to the Sankalp AI Discipline Coach and obtain mentor guidance.
     */
    public function chat(User $user, string $userMessage, ?int $conversationId = null): array
    {
        return DB::transaction(function () use ($user, $userMessage, $conversationId) {
            // 1. Resolve or create active conversation
            $conversation = $conversationId
                ? AiConversation::where('user_id', $user->id)->findOrFail($conversationId)
                : AiConversation::firstOrCreate(
                    ['user_id' => $user->id, 'title' => 'Sankalp Mentorship Session'],
                    ['user_id' => $user->id, 'title' => 'Sankalp Mentorship Session']
                );

            // 2. Build personalized user context
            $contextPrompt = $this->buildUserContextPrompt($user);

            // 3. Assemble chat message sequence
            $messages = [
                ['role' => 'system', 'content' => config('ai.system_prompt') . "\n\n" . $contextPrompt],
            ];

            // Append last 6 historical messages
            $recentHistory = $conversation->messages()
                ->latest()
                ->take(6)
                ->get()
                ->reverse();

            foreach ($recentHistory as $msg) {
                $messages[] = [
                    'role' => $msg->role,
                    'content' => $msg->content,
                ];
            }

            // Append current prompt
            $messages[] = [
                'role' => 'user',
                'content' => $userMessage,
            ];

            // 4. Save user message to database
            $savedUserMessage = AiMessage::create([
                'ai_conversation_id' => $conversation->id,
                'role' => 'user',
                'content' => $userMessage,
            ]);

            // 5. Query open-source LLM
            $llm = $this->llmManager->driver();
            $response = $llm->generateResponse($messages);

            // 6. Save assistant response
            $savedAssistantMessage = AiMessage::create([
                'ai_conversation_id' => $conversation->id,
                'role' => 'assistant',
                'content' => $response['content'],
            ]);

            // 7. Record token usage
            $today = now()->toDateString();
            $usage = AiUsageLog::firstOrNew([
                'user_id' => $user->id,
                'usage_date' => $today,
            ]);
            $usage->request_count = ($usage->request_count ?? 0) + 1;
            $usage->prompt_tokens = ($usage->prompt_tokens ?? 0) + $response['prompt_tokens'];
            $usage->completion_tokens = ($usage->completion_tokens ?? 0) + $response['completion_tokens'];
            $usage->save();

            return [
                'conversation_id' => $conversation->id,
                'message' => $savedAssistantMessage,
                'model' => $response['model'],
            ];
        });
    }

    /**
     * Synthesize dynamic context describing the user's current behavioral state.
     */
    protected function buildUserContextPrompt(User $user): string
    {
        $timezone = $user->profile?->timezone ?? 'Asia/Kolkata';
        $today = Carbon::now($timezone)->toDateString();

        $overallStreak = Streak::where('user_id', $user->id)
            ->whereNull('habit_id')
            ->first();

        $streakCount = $overallStreak ? $overallStreak->current_streak : 0;

        $activeChallenge = UserChallenge::where('user_id', $user->id)
            ->where('status', 'active')
            ->with('template')
            ->first();

        $challengeContext = 'No active challenge.';
        if ($activeChallenge) {
            $tasksToday = UserChallengeTask::where('user_challenge_id', $activeChallenge->id)
                ->where('scheduled_date', $today)
                ->get();

            $completedToday = $tasksToday->where('is_completed', true)->count();
            $totalToday = $tasksToday->count();

            $challengeContext = "Enrolled in: {$activeChallenge->title}. Today's task progress: {$completedToday}/{$totalToday} complete.";
        }

        $habitsDoneToday = HabitLog::where('user_id', $user->id)
            ->where('logged_date', $today)
            ->where('status', 'completed')
            ->count();

        return <<<CTX
CURRENT USER DISCIPLINE TELEMETRY:
- User Name: {$user->name}
- Current Streak: {$streakCount} consecutive days
- Habits Checked In Today: {$habitsDoneToday}
- Challenge Status: {$challengeContext}
- Preferred Tone: Concise, inspiring, focused on deliberate execution.
CTX;
    }
}
