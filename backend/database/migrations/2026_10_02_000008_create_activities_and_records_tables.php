<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->uuid('client_uuid')->unique(); // Idempotent sync key
            $table->enum('type', ['run', 'walk', 'cycle', 'hike'])->default('run')->index();
            $table->timestamp('started_at')->index();
            $table->timestamp('ended_at')->nullable();
            $table->string('timezone', 64)->default('Asia/Kolkata');
            $table->decimal('distance_m', 10, 2)->default(0.00)->index();
            $table->unsignedInteger('moving_time_s')->default(0);
            $table->unsignedInteger('elapsed_time_s')->default(0);
            $table->unsignedSmallInteger('avg_pace')->default(0); // seconds per km
            $table->decimal('max_speed', 6, 2)->default(0.00); // m/s
            $table->decimal('elevation_gain_m', 8, 2)->default(0.00);
            $table->unsignedSmallInteger('calories')->default(0);
            $table->mediumText('polyline')->nullable(); // Google Encoded Polyline
            $table->boolean('is_private')->default(true)->index();
            $table->string('source', 30)->default('arclife_native');
            $table->softDeletes();
            $table->timestamps();

            $table->index(['user_id', 'type', 'started_at'], 'idx_user_activity_search');
        });

        Schema::create('activity_splits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('activity_id')->constrained('activities')->cascadeOnDelete();
            $table->unsignedSmallInteger('split_index'); // 1, 2, 3..
            $table->decimal('distance_m', 8, 2);
            $table->unsignedSmallInteger('duration_s');
            $table->unsignedSmallInteger('pace_s'); // seconds per km
            $table->decimal('elevation_m', 6, 2)->default(0.00);
            $table->timestamps();

            $table->index(['activity_id', 'split_index'], 'idx_activity_splits');
        });

        Schema::create('personal_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('activity_type', ['run', 'walk', 'cycle', 'hike'])->default('run');
            $table->string('record_type', 40); // 'fastest_1k', 'fastest_5k', 'fastest_10k', 'longest_distance'
            $table->decimal('value', 10, 2); // seconds for pace/time records, meters for distance
            $table->foreignId('activity_id')->nullable()->constrained('activities')->nullOnDelete();
            $table->timestamp('achieved_at')->index();
            $table->timestamps();

            $table->unique(['user_id', 'activity_type', 'record_type'], 'uniq_user_pr');
        });

        Schema::create('activity_goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('goal_type', 40); // 'weekly_distance_m', 'weekly_count', 'challenge_run_streak'
            $table->decimal('target_value', 10, 2);
            $table->decimal('current_value', 10, 2)->default(0.00);
            $table->date('period_start');
            $table->date('period_end');
            $table->boolean('is_achieved')->default(false)->index();
            $table->timestamps();

            $table->index(['user_id', 'period_start', 'period_end'], 'idx_user_goal_period');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_goals');
        Schema::dropIfExists('personal_records');
        Schema::dropIfExists('activity_splits');
        Schema::dropIfExists('activities');
    }
};
