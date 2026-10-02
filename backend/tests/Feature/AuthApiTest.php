<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_user_can_onboard_instantly(): void
    {
        $response = $this->postJson('/api/v1/auth/guest', [
            'device_uuid' => 'test-device-uuid-12345',
            'timezone' => 'Asia/Kolkata',
            'language' => 'en',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'user' => ['id', 'uuid', 'is_guest'],
                    'token',
                    'token_type',
                ],
            ]);

        $this->assertTrue($response->json('data.user.is_guest'));
    }

    public function test_user_can_register_with_email_and_password(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Vikram Aditya',
            'email' => 'vikram@sankalp.test',
            'password' => 'Discipline2026!',
            'timezone' => 'Asia/Kolkata',
            'language' => 'en',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.email', 'vikram@sankalp.test');

        $this->assertDatabaseHas('users', [
            'email' => 'vikram@sankalp.test',
            'is_guest' => false,
        ]);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'arjun@sankalp.test',
            'password' => bcrypt('Discipline2026!'),
            'is_guest' => false,
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'arjun@sankalp.test',
            'password' => 'Discipline2026!',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['token', 'user']]);
    }

    public function test_guest_can_upgrade_to_permanent_account(): void
    {
        // 1. Create guest
        $guestRes = $this->postJson('/api/v1/auth/guest', [
            'device_uuid' => 'guest-upgrade-device-999',
        ]);
        $token = $guestRes->json('data.token');

        // 2. Upgrade guest
        $response = $this->withToken($token)->postJson('/api/v1/auth/upgrade', [
            'name' => 'Permanent Disciple',
            'email' => 'converted@sankalp.test',
            'password' => 'PermanentPassword123!',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.is_guest', false)
            ->assertJsonPath('data.user.email', 'converted@sankalp.test');

        $this->assertDatabaseHas('users', [
            'email' => 'converted@sankalp.test',
            'is_guest' => false,
        ]);
    }

    public function test_authenticated_user_can_fetch_me_profile(): void
    {
        $user = User::factory()->create(['name' => 'Karna Warrior']);

        $response = $this->actingAs($user)->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.name', 'Karna Warrior');
    }

    public function test_user_can_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withToken($token)->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertCount(0, $user->fresh()->tokens);
    }
}
