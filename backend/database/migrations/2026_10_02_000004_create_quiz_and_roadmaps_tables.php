<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quiz_questions', function (Blueprint $table) {
            $table->id();
            $table->string('dimension', 30)->index(); // 'sleep', 'digital', 'physical', 'mindset'
            $table->unsignedSmallInteger('order_number')->index();
            $table->text('question_en');
            $table->text('question_hi');
            $table->timestamps();
        });

        Schema::create('quiz_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_question_id')->constrained('quiz_questions')->cascadeOnDelete();
            $table->unsignedTinyInteger('score_points'); // 1, 2, 3, 4
            $table->text('option_en');
            $table->text('option_hi');
            $table->timestamps();

            $table->index(['quiz_question_id', 'score_points'], 'idx_question_score');
        });

        Schema::create('quiz_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedSmallInteger('total_score'); // 16..64
            $table->decimal('life_balance_index', 5, 2); // 0.00..100.00 %
            $table->string('recommended_tier', 40); // 'Dopamine Burnout', 'Inconsistent Seeker', etc.
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'created_at'], 'idx_user_quiz_attempts');
        });

        Schema::create('quiz_answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_attempt_id')->constrained('quiz_attempts')->cascadeOnDelete();
            $table->foreignId('quiz_question_id')->constrained('quiz_questions')->cascadeOnDelete();
            $table->foreignId('quiz_option_id')->constrained('quiz_options')->cascadeOnDelete();
            $table->unsignedTinyInteger('score');
            $table->timestamps();

            $table->index(['quiz_attempt_id', 'quiz_question_id'], 'idx_attempt_question');
        });

        Schema::create('roadmaps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('quiz_attempt_id')->nullable()->constrained('quiz_attempts')->nullOnDelete();
            $table->string('title');
            $table->string('tier', 50);
            $table->string('target_challenge_slug', 64);
            $table->enum('status', ['active', 'archived'])->default('active')->index();
            $table->timestamps();

            $table->index(['user_id', 'status'], 'idx_user_roadmap_status');
        });

        Schema::create('roadmap_phases', function (Blueprint $table) {
            $table->id();
            $table->foreignId('roadmap_id')->constrained('roadmaps')->cascadeOnDelete();
            $table->unsignedTinyInteger('phase_number'); // 1, 2, 3
            $table->string('title');
            $table->text('focus');
            $table->unsignedSmallInteger('duration_days')->default(30);
            $table->boolean('is_unlocked')->default(false);
            $table->timestamps();

            $table->index(['roadmap_id', 'phase_number'], 'idx_roadmap_phase');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('roadmap_phases');
        Schema::dropIfExists('roadmaps');
        Schema::dropIfExists('quiz_answers');
        Schema::dropIfExists('quiz_attempts');
        Schema::dropIfExists('quiz_options');
        Schema::dropIfExists('quiz_questions');
    }
};
