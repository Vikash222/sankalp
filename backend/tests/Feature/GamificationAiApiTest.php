<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\BadgeSeeder;
use Database\Seeders\LevelSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GamificationAiApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(LevelSeeder::class);
        $this->seed(BadgeSeeder::class);
    }

    public function test_can_fetch_gamification_profile_badges_and_leaderboard(): void
    {
        $user = User::factory()->create(['name' => 'Bheeshma Leader']);

        // Profile
        $profileRes = $this->actingAs($user)->getJson('/api/v1/gamification/profile');
        $profileRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'total_xp',
                    'level',
                    'level_title',
                    'level_progress_percentage',
                    'badges_count',
                    'total_available_badges',
                ],
            ]);

        // Badges
        $badgesRes = $this->actingAs($user)->getJson('/api/v1/gamification/badges');
        $badgesRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(30, 'data');

        // Leaderboard
        $leaderboardRes = $this->actingAs($user)->getJson('/api/v1/gamification/leaderboard');
        $leaderboardRes->assertStatus(200)
            ->assertJsonPath('success', true);
    }

    public function test_can_chat_with_sankalp_ai_discipline_coach(): void
    {
        $user = User::factory()->create(['name' => 'Seeking Guidance']);

        $response = $this->actingAs($user)->postJson('/api/v1/ai/chat', [
            'message' => 'I feel lethargic and want to scroll on social media. What should I do?',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'conversation_id',
                    'message' => [
                        'id',
                        'role',
                        'content',
                    ],
                    'model',
                ],
            ]);

        $this->assertEquals('assistant', $response->json('data.message.role'));
        $this->assertNotEmpty($response->json('data.message.content'));
    }

    public function test_can_record_focus_session_and_configure_app_blocker(): void
    {
        $user = User::factory()->create();

        // 1. Record deep work session
        $focusRes = $this->actingAs($user)->postJson('/api/v1/focus/sessions', [
            'duration_minutes' => 45,
            'mode' => 'deep_work',
            'notes' => 'Finished module refactoring without phone interruption.',
        ]);

        $focusRes->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.session.duration_minutes', 45)
            ->assertJsonPath('data.gamification.awarded_xp', 45);

        // 2. Add app blocker rule
        $blockerRes = $this->actingAs($user)->postJson('/api/v1/blocker/rules', [
            'package_name' => 'com.instagram.android',
            'app_name' => 'Instagram',
            'daily_limit_minutes' => 15,
            'is_blocked' => true,
        ]);

        $blockerRes->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.package_name', 'com.instagram.android')
            ->assertJsonPath('data.is_blocked', true);
    }
}
