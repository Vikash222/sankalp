<?php

namespace Database\Seeders;

use App\Models\NotificationSetting;
use App\Models\Streak;
use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            LevelSeeder::class,
            BadgeSeeder::class,
            QuizSeeder::class,
            ChallengeTemplateSeeder::class,
        ]);

        // Demo User for tests & initial development
        $demoUser = User::updateOrCreate(
            ['email' => 'aryan@sankalp.app'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Aryan Sharma',
                'password' => bcrypt('Password123!'),
                'is_guest' => false,
            ]
        );

        UserProfile::updateOrCreate(
            ['user_id' => $demoUser->id],
            [
                'bio' => 'Engineering Aspirant | Conqueror of Winter Arc',
                'weight_kg' => 72.50,
                'height_cm' => 178.00,
                'language' => 'en',
                'theme' => 'day',
                'timezone' => 'Asia/Kolkata',
                'daily_water_target_ml' => 3500,
                'screen_time_target_min' => 120,
            ]
        );

        NotificationSetting::updateOrCreate(
            ['user_id' => $demoUser->id],
            [
                'morning_enabled' => true,
                'morning_time' => '05:30:00',
                'midday_enabled' => true,
                'evening_enabled' => true,
            ]
        );

        Streak::updateOrCreate(
            ['user_id' => $demoUser->id, 'habit_id' => null],
            [
                'current_streak' => 7,
                'longest_streak' => 14,
                'last_completed_date' => now()->toDateString(),
                'freeze_count' => 2,
            ]
        );
    }
}
