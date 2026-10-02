<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\ChallengeTemplateSeeder;
use Database\Seeders\QuizSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class QuizRoadmapApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(QuizSeeder::class);
        $this->seed(ChallengeTemplateSeeder::class);
    }

    public function test_can_fetch_quiz_questions_with_options(): void
    {
        $response = $this->getJson('/api/v1/quiz/questions');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(16, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'dimension',
                        'order_number',
                        'question_en',
                        'options' => [
                            '*' => ['id', 'score_points', 'option_en'],
                        ],
                    ],
                ],
            ]);
    }

    public function test_can_submit_quiz_and_generate_personalized_roadmap(): void
    {
        $user = User::factory()->create();

        // Fetch questions to build answer payload
        $questionsRes = $this->getJson('/api/v1/quiz/questions');
        $questions = $questionsRes->json('data');

        $answers = [];
        foreach ($questions as $q) {
            $answers[] = [
                'question_id' => $q['id'],
                'option_id' => $q['options'][0]['id'],
            ];
        }

        $response = $this->actingAs($user)->postJson('/api/v1/quiz/submit', [
            'answers' => $answers,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'archetype',
                    'life_balance_index',
                    'target_challenge_slug',
                    'roadmap' => [
                        'id',
                        'title',
                        'tier',
                        'phases' => [
                            '*' => ['id', 'phase_number', 'title', 'duration_days'],
                        ],
                    ],
                ],
            ]);

        // Verify active roadmap retrieval endpoint
        $roadmapRes = $this->actingAs($user)->getJson('/api/v1/roadmap/current');
        $roadmapRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_active', true);
    }
}
