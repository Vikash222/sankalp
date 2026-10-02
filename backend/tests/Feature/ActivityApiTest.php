<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\BadgeSeeder;
use Database\Seeders\LevelSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ActivityApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(LevelSeeder::class);
        $this->seed(BadgeSeeder::class);
    }

    public function test_can_record_legitimate_gps_run_with_splits_and_xp(): void
    {
        $user = User::factory()->create();

        $payload = [
            'client_uuid' => 'gps-run-sync-uuid-001',
            'type' => 'run',
            'started_at' => now()->subMinutes(30)->toIso8601String(),
            'ended_at' => now()->toIso8601String(),
            'distance_m' => 5000.0,
            'moving_time_s' => 1500, // 25 minutes = 12 km/h (valid run pace: 5:00 min/km)
            'elapsed_time_s' => 1600,
            'avg_pace' => 300,
            'max_speed' => 4.5, // 4.5 m/s = 16.2 km/h (valid running sprint)
            'elevation_gain_m' => 45.0,
            'calories' => 350,
            'polyline' => '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
            'is_private' => true,
            'splits' => [
                [
                    'split_number' => 1,
                    'distance_m' => 1000,
                    'elapsed_time_s' => 300,
                    'pace_seconds_per_km' => 300,
                    'elevation_change_m' => 10.0,
                ],
                [
                    'split_number' => 2,
                    'distance_m' => 1000,
                    'elapsed_time_s' => 295,
                    'pace_seconds_per_km' => 295,
                    'elevation_change_m' => 5.0,
                ],
            ],
        ];

        $response = $this->actingAs($user)->postJson('/api/v1/activities', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_flagged', false)
            ->assertJsonPath('data.is_duplicate', false)
            ->assertJsonPath('data.gamification.awarded_xp', 70); // 20 bonus + 50 (5km * 10)

        $this->assertDatabaseHas('activities', [
            'client_uuid' => 'gps-run-sync-uuid-001',
            'user_id' => $user->id,
            'distance_m' => 5000.0,
        ]);

        $this->assertDatabaseHas('activity_splits', [
            'split_index' => 1,
            'distance_m' => 1000,
        ]);

        // Check PR creation
        $this->assertDatabaseHas('personal_records', [
            'user_id' => $user->id,
            'activity_type' => 'run',
            'record_type' => 'longest_distance',
            'value' => 5000.0,
        ]);
    }

    public function test_activity_sync_is_idempotent(): void
    {
        $user = User::factory()->create();

        $payload = [
            'client_uuid' => 'gps-idempotent-uuid-002',
            'type' => 'walk',
            'started_at' => now()->subMinutes(20)->toIso8601String(),
            'ended_at' => now()->toIso8601String(),
            'distance_m' => 2000.0,
            'moving_time_s' => 1200,
        ];

        // First submission
        $res1 = $this->actingAs($user)->postJson('/api/v1/activities', $payload);
        $res1->assertStatus(201)
            ->assertJsonPath('data.is_duplicate', false);

        // Second duplicate submission
        $res2 = $this->actingAs($user)->postJson('/api/v1/activities', $payload);
        $res2->assertStatus(200)
            ->assertJsonPath('data.is_duplicate', true);
    }

    public function test_anti_cheat_flags_vehicle_speed(): void
    {
        $user = User::factory()->create();

        // 10km in 10 minutes = 60 km/h (impossible human run, car/train)
        $payload = [
            'client_uuid' => 'gps-cheat-vehicle-003',
            'type' => 'run',
            'started_at' => now()->subMinutes(10)->toIso8601String(),
            'ended_at' => now()->toIso8601String(),
            'distance_m' => 10000.0,
            'moving_time_s' => 600, // 60 km/h
            'max_speed' => 22.0, // 22 m/s = 79.2 km/h
        ];

        $response = $this->actingAs($user)->postJson('/api/v1/activities', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('data.is_flagged', true)
            ->assertJsonPath('data.gamification', null);

        $this->assertDatabaseHas('activities', [
            'client_uuid' => 'gps-cheat-vehicle-003',
            'source' => 'flagged_vehicle',
        ]);
    }

    public function test_can_fetch_activity_statistics_and_gpx_export(): void
    {
        $user = User::factory()->create();

        $payload = [
            'client_uuid' => 'gps-export-test-004',
            'type' => 'cycle',
            'started_at' => now()->subMinutes(40)->toIso8601String(),
            'ended_at' => now()->toIso8601String(),
            'distance_m' => 12000.0,
            'moving_time_s' => 2400,
            'calories' => 420,
        ];

        $createRes = $this->actingAs($user)->postJson('/api/v1/activities', $payload);
        $activityId = $createRes->json('data.activity.id');

        // Stats
        $statsRes = $this->actingAs($user)->getJson('/api/v1/activities/stats');
        $statsRes->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.all_time.total_workouts', 1);

        // GPX export
        $gpxRes = $this->actingAs($user)->get("/api/v1/activities/{$activityId}/gpx");
        $gpxRes->assertStatus(200)
            ->assertHeader('Content-Type', 'application/gpx+xml');
        $this->assertStringContainsString('<gpx', $gpxRes->getContent());
    }
}
