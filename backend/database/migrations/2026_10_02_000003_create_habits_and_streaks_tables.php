<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('habits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->string('title_hi')->nullable();
            $table->text('description')->nullable();
            $table->string('category', 50)->default('general'); // 'health', 'focus', 'mindset', 'fitness'
            $table->enum('cadence', ['daily', 'weekdays', 'weekly'])->default('daily');
            $table->unsignedInteger('target_value')->default(1);
            $table->string('unit', 30)->default('times'); // 'times', 'minutes', 'ml', 'pages'
            $table->time('reminder_time')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->softDeletes();
            $table->timestamps();

            $table->index(['user_id', 'is_active'], 'idx_user_active_habits');
        });

        Schema::create('habit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('habit_id')->constrained('habits')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('log_date');
            $table->boolean('is_completed')->default(true)->index();
            $table->unsignedInteger('logged_value')->default(1);
            $table->string('note', 255)->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->unique(['habit_id', 'log_date'], 'uniq_habit_daily_log');
            $table->index(['user_id', 'log_date'], 'idx_user_log_date');
            $table->index(['user_id', 'is_completed', 'log_date'], 'idx_user_completed_date');
        });

        Schema::create('streaks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('habit_id')->nullable()->constrained('habits')->cascadeOnDelete();
            $table->unsignedInteger('current_streak')->default(0);
            $table->unsignedInteger('longest_streak')->default(0);
            $table->date('last_completed_date')->nullable();
            $table->unsignedTinyInteger('freeze_count')->default(0); // Available freezes (max 2)
            $table->timestamps();

            $table->index(['user_id', 'habit_id'], 'idx_user_habit_streak');
            $table->index(['user_id', 'last_completed_date'], 'idx_user_last_comp');
        });

        Schema::create('streak_freezes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('streak_id')->constrained('streaks')->cascadeOnDelete();
            $table->date('used_for_date');
            $table->enum('status', ['earned', 'used', 'expired'])->default('used');
            $table->timestamp('earned_at')->nullable();
            $table->timestamp('used_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status'], 'idx_user_freeze_status');
            $table->unique(['streak_id', 'used_for_date'], 'uniq_streak_freeze_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('streak_freezes');
        Schema::dropIfExists('streaks');
        Schema::dropIfExists('habit_logs');
        Schema::dropIfExists('habits');
    }
};
