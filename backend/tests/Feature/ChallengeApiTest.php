<?php

namespace Tests\Feature;

use App\Models\ChallengeTemplate;
use App\Models\User;
use Database\Seeders\ChallengeTemplateSeeder;
use Database\Seeders\LevelSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ChallengeApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(LevelSeeder::class);
        $this->seed(ChallengeTemplateSeeder::class);
    }

    public function test_can_list_challenge_templates(): void
    {
        $response = $this->getJson('/api/v1/challenges/templates');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'slug', 'title', 'duration_days', 'difficulty'],
                ],
            ]);
    }

    public function test_user_can_start_challenge_and_fetch_active_progress(): void
    {
        $user = User::factory()->create();
        $template = ChallengeTemplate::where('slug', '21-day-habit-builder')->first();

        // 1. Start challenge
        $startRes = $this->actingAs($user)->postJson('/api/v1/challenges/start', [
            'template_id' => $template->id,
        ]);

        $startRes->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'active')
            ->assertJsonPath('data.current_day', 1);

        // 2. Fetch active challenge
        $activeRes = $this->actingAs($user)->getJson('/api/v1/challenges/active');
        $activeRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.challenge_template_id', $template->id);

        // 3. Fetch today's tasks
        $todayRes = $this->actingAs($user)->getJson('/api/v1/challenges/today');
        $todayRes->assertStatus(200)
            ->assertJsonPath('success', true);

        $tasks = $todayRes->json('data');
        $this->assertNotEmpty($tasks);
        $firstTaskId = $tasks[0]['id'];

        // 4. Toggle task completion
        $toggleRes = $this->actingAs($user)->postJson("/api/v1/challenges/tasks/{$firstTaskId}/toggle", [
            'is_completed' => true,
        ]);

        $toggleRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.task.is_completed', true)
            ->assertJsonPath('data.gamification.awarded_xp', 15);
    }
}
