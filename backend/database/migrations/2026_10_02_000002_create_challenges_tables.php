<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('challenge_templates', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 64)->unique();
            $table->string('title');
            $table->string('title_hi');
            $table->text('description');
            $table->text('description_hi');
            $table->unsignedSmallInteger('duration_days')->default(21);
            $table->enum('difficulty', ['beginner', 'intermediate', 'hardcore'])->default('beginner');
            $table->string('category', 50)->default('general'); // 'habit', 'transformation', 'summer_arc', 'winter_arc'
            $table->boolean('is_active')->default(true)->index();
            $table->softDeletes();
            $table->timestamps();
        });

        Schema::create('challenge_template_tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('challenge_template_id')->constrained('challenge_templates')->cascadeOnDelete();
            $table->unsignedSmallInteger('day_number'); // 1..90
            $table->string('title');
            $table->string('title_hi');
            $table->text('description')->nullable();
            $table->text('description_hi')->nullable();
            $table->enum('task_type', ['boolean', 'duration_timer', 'numeric_counter'])->default('boolean');
            $table->unsignedInteger('target_value')->default(1); // e.g. 25 minutes or 3000 ml
            $table->boolean('is_recovery_day')->default(false);
            $table->unsignedSmallInteger('xp_reward')->default(25);
            $table->timestamps();

            $table->index(['challenge_template_id', 'day_number'], 'idx_template_day');
        });

        Schema::create('user_challenges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('challenge_template_id')->constrained('challenge_templates')->restrictOnDelete();
            $table->date('started_at');
            $table->date('completed_at')->nullable();
            $table->enum('status', ['active', 'paused', 'completed', 'abandoned'])->default('active')->index();
            $table->unsignedSmallInteger('current_day')->default(1);
            $table->boolean('is_comeback_mode')->default(false);
            $table->timestamp('comeback_expires_at')->nullable();
            $table->softDeletes();
            $table->timestamps();

            $table->index(['user_id', 'status'], 'idx_user_challenge_status');
        });

        Schema::create('user_challenge_tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_challenge_id')->constrained('user_challenges')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedSmallInteger('day_number');
            $table->string('task_title');
            $table->string('task_title_hi')->nullable();
            $table->boolean('is_completed')->default(false)->index();
            $table->timestamp('completed_at')->nullable();
            $table->unsignedSmallInteger('xp_awarded')->default(0);
            $table->timestamps();

            $table->index(['user_challenge_id', 'day_number'], 'idx_user_chal_task_day');
            $table->index(['user_id', 'is_completed', 'completed_at'], 'idx_user_task_comp');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_challenge_tasks');
        Schema::dropIfExists('user_challenges');
        Schema::dropIfExists('challenge_template_tasks');
        Schema::dropIfExists('challenge_templates');
    }
};
