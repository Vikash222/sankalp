<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->boolean('morning_enabled')->default(true);
            $table->time('morning_time')->default('06:00:00');
            $table->boolean('midday_enabled')->default(true);
            $table->time('midday_time')->default('14:00:00');
            $table->boolean('evening_enabled')->default(true);
            $table->time('evening_time')->default('20:30:00');
            $table->boolean('streak_risk_enabled')->default(true);
            $table->boolean('comeback_enabled')->default(true);
            $table->boolean('sound_enabled')->default(true);
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::create('scheduled_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('device_id')->nullable()->constrained('devices')->nullOnDelete();
            $table->string('type', 40)->index(); // 'morning', 'midday', 'evening', 'streak_risk', 'comeback'
            $table->dateTime('scheduled_at')->index();
            $table->dateTime('sent_at')->nullable();
            $table->enum('status', ['pending', 'sent', 'failed', 'cancelled'])->default('pending')->index();
            $table->string('title');
            $table->string('body');
            $table->json('payload')->nullable();
            $table->timestamps();

            $table->index(['status', 'scheduled_at'], 'idx_sched_notif_status_time');
        });

        Schema::create('focus_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedSmallInteger('duration_minutes');
            $table->unsignedSmallInteger('completed_minutes')->default(0);
            $table->enum('mode', ['pomodoro', 'monk_mode', 'deep_work'])->default('pomodoro');
            $table->boolean('is_successful')->default(true);
            $table->timestamp('started_at');
            $table->timestamp('ended_at')->nullable();
            $table->unsignedSmallInteger('interruption_count')->default(0);
            $table->timestamps();

            $table->index(['user_id', 'started_at'], 'idx_user_focus_time');
        });

        Schema::create('blocked_app_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('package_name', 128); // e.g. 'com.instagram.android'
            $table->string('app_name', 100);
            $table->boolean('is_blocked')->default(true);
            $table->unsignedSmallInteger('daily_limit_minutes')->default(0);
            $table->timestamps();

            $table->unique(['user_id', 'package_name'], 'uniq_user_pkg_rule');
            $table->index(['user_id', 'is_blocked'], 'idx_user_blocked_rules');
        });

        Schema::create('usage_stats_daily', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('stat_date');
            $table->unsignedInteger('total_screen_time_seconds')->default(0);
            $table->unsignedSmallInteger('unlock_count')->default(0);
            $table->unsignedSmallInteger('pickups')->default(0);
            $table->json('top_apps_json')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'stat_date'], 'uniq_user_daily_stat');
            $table->index(['user_id', 'stat_date'], 'idx_user_stat_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('usage_stats_daily');
        Schema::dropIfExists('blocked_app_rules');
        Schema::dropIfExists('focus_sessions');
        Schema::dropIfExists('scheduled_notifications');
        Schema::dropIfExists('notification_settings');
    }
};
