<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('journal_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('entry_date');
            $table->text('content');
            $table->string('reflection_prompt')->nullable();
            $table->boolean('is_encrypted')->default(false);
            $table->json('tags_json')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'entry_date'], 'uniq_user_journal_date');
        });

        Schema::create('moods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('mood_date');
            $table->unsignedTinyInteger('score'); // 1..5
            $table->unsignedTinyInteger('energy_level')->default(3); // 1..5
            $table->json('tags_json')->nullable();
            $table->string('note', 255)->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'mood_date'], 'uniq_user_mood_date');
            $table->index(['user_id', 'score'], 'idx_user_mood_score');
        });

        Schema::create('xp_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->integer('amount'); // Positive or negative
            $table->string('source_type', 50)->index(); // 'habit_checkin', 'challenge_task', 'focus_session', 'journal'
            $table->unsignedBigInteger('source_id')->nullable();
            $table->string('description', 255);
            $table->timestamps();

            $table->index(['user_id', 'created_at'], 'idx_user_xp_time');
        });

        Schema::create('levels', function (Blueprint $table) {
            $table->id();
            $table->unsignedSmallInteger('level_number')->unique();
            $table->string('title');
            $table->string('title_hi');
            $table->unsignedInteger('min_xp')->index();
            $table->timestamps();
        });

        Schema::create('badges', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 64)->unique();
            $table->string('title');
            $table->string('title_hi');
            $table->text('description');
            $table->text('description_hi');
            $table->enum('tier', ['bronze', 'silver', 'gold', 'platinum', 'diamond'])->default('bronze');
            $table->string('icon', 64)->default('badge_default');
            $table->json('unlock_criteria_json')->nullable();
            $table->timestamps();
        });

        Schema::create('user_badges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('badge_id')->constrained('badges')->cascadeOnDelete();
            $table->timestamp('unlocked_at');
            $table->timestamps();

            $table->unique(['user_id', 'badge_id'], 'uniq_user_badge');
            $table->index(['user_id', 'unlocked_at'], 'idx_user_badge_unlock');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_badges');
        Schema::dropIfExists('badges');
        Schema::dropIfExists('levels');
        Schema::dropIfExists('xp_transactions');
        Schema::dropIfExists('moods');
        Schema::dropIfExists('journal_entries');
    }
};
