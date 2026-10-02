<?php

namespace Tests\Unit;

use App\Models\Streak;
use App\Models\User;
use App\Models\UserProfile;
use App\Services\StreakService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class StreakServiceTest extends TestCase
{
    use RefreshDatabase;

    private StreakService $service;
    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new StreakService();

        $this->user = User::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'Streak Tester',
            'email' => 'streaker@arclife.app',
            'password' => bcrypt('secret'),
        ]);

        UserProfile::create([
            'user_id' => $this->user->id,
            'timezone' => 'Asia/Kolkata',
        ]);
    }

    public function test_first_checkin_initializes_streak_to_one(): void
    {
        $result = $this->service->recordCheckin($this->user, null, '2026-10-01');

        $this->assertTrue($result['incremented']);
        $this->assertFalse($result['freeze_consumed']);
        $this->assertEquals(1, $result['streak']->current_streak);
        $this->assertEquals('2026-10-01', $result['streak']->last_completed_date->toDateString());
    }

    public function test_same_day_checkin_is_idempotent(): void
    {
        $this->service->recordCheckin($this->user, null, '2026-10-01');
        $secondResult = $this->service->recordCheckin($this->user, null, '2026-10-01');

        $this->assertFalse($secondResult['incremented']);
        $this->assertEquals(1, $secondResult['streak']->current_streak);
    }

    public function test_consecutive_checkin_increments_streak(): void
    {
        $this->service->recordCheckin($this->user, null, '2026-10-01');
        $day2Result = $this->service->recordCheckin($this->user, null, '2026-10-02');

        $this->assertTrue($day2Result['incremented']);
        $this->assertEquals(2, $day2Result['streak']->current_streak);
        $this->assertEquals(2, $day2Result['streak']->longest_streak);
    }

    public function test_seven_consecutive_days_awards_streak_freeze(): void
    {
        for ($day = 1; $day <= 7; $day++) {
            $date = sprintf('2026-10-%02d', $day);
            $this->service->recordCheckin($this->user, null, $date);
        }

        $streak = Streak::where('user_id', $this->user->id)->first();
        $this->assertEquals(7, $streak->current_streak);
        $this->assertEquals(1, $streak->freeze_count);
    }

    public function test_missed_one_day_with_freeze_consumes_freeze_and_keeps_streak(): void
    {
        // Give user an active 6-day streak with 1 freeze
        $streak = Streak::create([
            'user_id' => $this->user->id,
            'habit_id' => null,
            'current_streak' => 6,
            'longest_streak' => 6,
            'last_completed_date' => '2026-10-01',
            'freeze_count' => 1,
        ]);

        // Missed 2026-10-02, checking in on 2026-10-03
        $result = $this->service->recordCheckin($this->user, null, '2026-10-03');

        $this->assertTrue($result['freeze_consumed']);
        $this->assertEquals(7, $result['streak']->current_streak); // 6 + 1 (saved)
        $this->assertEquals(0, $result['streak']->freeze_count);
        $this->assertDatabaseHas('streak_freezes', [
            'user_id' => $this->user->id,
            'status' => 'used',
        ]);
    }

    public function test_missed_day_without_freeze_resets_streak_to_one(): void
    {
        $streak = Streak::create([
            'user_id' => $this->user->id,
            'habit_id' => null,
            'current_streak' => 12,
            'longest_streak' => 12,
            'last_completed_date' => '2026-10-01',
            'freeze_count' => 0,
        ]);

        // Missed 2026-10-02, checking in on 2026-10-03
        $result = $this->service->recordCheckin($this->user, null, '2026-10-03');

        $this->assertFalse($result['freeze_consumed']);
        $this->assertEquals(1, $result['streak']->current_streak);
        $this->assertEquals(12, $result['streak']->longest_streak); // Longest preserved
    }
}
