<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('avatar_url')->nullable();
            $table->text('bio')->nullable();
            $table->decimal('weight_kg', 5, 2)->default(70.00);
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->date('birth_date')->nullable();
            $table->time('wake_time')->default('06:00:00');
            $table->time('sleep_time')->default('23:00:00');
            $table->unsignedInteger('daily_water_target_ml')->default(3000);
            $table->unsignedInteger('screen_time_target_min')->default(180);
            $table->string('language', 10)->default('en')->index(); // 'en', 'hi'
            $table->string('theme', 20)->default('dark'); // 'dark', 'light'
            $table->string('timezone', 64)->default('Asia/Kolkata')->index();
            $table->softDeletes();
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::create('devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('device_id')->index(); // Unique per physical hardware
            $table->string('fcm_token', 512)->nullable()->index();
            $table->string('platform', 20)->default('android'); // 'android', 'ios'
            $table->string('app_version', 30)->nullable();
            $table->string('timezone', 64)->default('Asia/Kolkata')->index();
            $table->timestamp('last_active_at')->nullable()->index();
            $table->timestamps();

            $table->unique(['user_id', 'device_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('devices');
        Schema::dropIfExists('user_profiles');
    }
};
