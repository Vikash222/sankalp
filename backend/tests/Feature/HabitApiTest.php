<?php

namespace Tests\Feature;

use App\Models\Habit;
use App\Models\User;
use Database\Seeders\LevelSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class HabitApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(LevelSeeder::class);
    }

    public function test_can_create_habit(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/habits', [
            'title' => 'Morning Cold Shower',
            'category' => 'fitness',
            'cadence' => 'daily',
            'target_value' => 1,
            'unit' => 'times',
            'reminder_time' => '06:00:00',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Morning Cold Shower')
            ->assertJsonPath('data.is_active', true);

        $this->assertDatabaseHas('habits', [
            'user_id' => $user->id,
            'title' => 'Morning Cold Shower',
        ]);
    }

    public function test_can_checkin_habit_and_advance_streak(): void
    {
        $user = User::factory()->create();
        $habit = Habit::create([
            'user_id' => $user->id,
            'title' => 'Deep Breathing & Pranayama',
            'category' => 'mindset',
            'cadence' => 'daily',
            'target_value' => 10,
            'unit' => 'minutes',
            'is_active' => true,
        ]);

        $response = $this->actingAs($user)->postJson("/api/v1/habits/{$habit->id}/checkin", [
            'notes' => '10 minutes of box breathing completed.',
            'numeric_value' => 10,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.current_streak', 1)
            ->assertJsonPath('data.overall_streak', 1)
            ->assertJsonPath('data.gamification.awarded_xp', 20);

        $this->assertDatabaseHas('habit_logs', [
            'habit_id' => $habit->id,
            'user_id' => $user->id,
            'is_completed' => true,
        ]);
    }

    public function test_can_fetch_habit_heatmap(): void
    {
        $user = User::factory()->create();
        $habit = Habit::create([
            'user_id' => $user->id,
            'title' => 'Read Philosophy',
            'category' => 'focus',
            'cadence' => 'daily',
            'target_value' => 20,
            'unit' => 'pages',
            'is_active' => true,
        ]);

        // Check in
        $this->actingAs($user)->postJson("/api/v1/habits/{$habit->id}/checkin");

        // Fetch heatmap
        $response = $this->actingAs($user)->getJson("/api/v1/habits/{$habit->id}/heatmap");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.total_checkins', 1);
    }
}
