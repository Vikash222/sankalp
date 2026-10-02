<?php

namespace Database\Seeders;

use App\Models\ChallengeTemplate;
use App\Models\ChallengeTemplateTask;
use Illuminate\Database\Seeder;

class ChallengeTemplateSeeder extends Seeder
{
    public function run(): void
    {
        $this->seed21DayHabitBuilder();
        $this->seed90DayTransformation();
        $this->seedSummerArc();
        $this->seedWinterArc();
    }

    private function seed21DayHabitBuilder(): void
    {
        $template = ChallengeTemplate::updateOrCreate(
            ['slug' => '21-day-habit-builder'],
            [
                'title' => '21-Day Habit Builder',
                'title_hi' => '21-दिवसीय आदत निर्माता',
                'description' => 'The ultimate friction breaker. Build 3 unbreakable daily keystone habits in 3 weeks.',
                'description_hi' => 'आदत निर्माण की नींव। 3 सप्ताह में 3 अटूट दैनिक आदतें बनाएं।',
                'duration_days' => 21,
                'difficulty' => 'beginner',
                'category' => 'habit',
                'is_active' => true,
            ]
        );

        for ($day = 1; $day <= 21; $day++) {
            $isRecovery = ($day % 7 === 0);

            if ($isRecovery) {
                ChallengeTemplateTask::create([
                    'challenge_template_id' => $template->id,
                    'day_number' => $day,
                    'title' => 'Day ' . $day . ': Active Recovery & Reflection',
                    'title_hi' => 'दिन ' . $day . ': सक्रिय रिकवरी और आत्मचिंतन',
                    'description' => 'Go for a gentle 15-minute nature walk and write down 3 insights gained this week.',
                    'description_hi' => '15 मिनट की शांत सैर करें और इस सप्ताह सीखी गई 3 मुख्य बातें लिखें।',
                    'task_type' => 'boolean',
                    'target_value' => 1,
                    'is_recovery_day' => true,
                    'xp_reward' => 50,
                ]);
            } else {
                ChallengeTemplateTask::create([
                    'challenge_template_id' => $template->id,
                    'day_number' => $day,
                    'title' => 'Morning Hydration & Sunlight (Day ' . $day . ')',
                    'title_hi' => 'सुबह का पानी और धूप (दिन ' . $day . ')',
                    'description' => 'Drink 500ml water immediately on waking and get 5 minutes of direct sunlight.',
                    'description_hi' => 'जागते ही 500 मिली पानी पिएं और 5 मिनट सीधी धूप लें।',
                    'task_type' => 'boolean',
                    'target_value' => 1,
                    'is_recovery_day' => false,
                    'xp_reward' => 25,
                ]);

                ChallengeTemplateTask::create([
                    'challenge_template_id' => $template->id,
                    'day_number' => $day,
                    'title' => '25-Minute Single-Task Pomodoro',
                    'title_hi' => '25-मिनट का एकाग्र पोमोडोरो सत्र',
                    'description' => 'Work or study for 25 minutes with smartphone locked and notifications silenced.',
                    'description_hi' => 'फोन को दूर रखकर बिना रुकावट के 25 मिनट अध्ययन या कार्य करें।',
                    'task_type' => 'duration_timer',
                    'target_value' => 25,
                    'is_recovery_day' => false,
                    'xp_reward' => 30,
                ]);

                ChallengeTemplateTask::create([
                    'challenge_template_id' => $template->id,
                    'day_number' => $day,
                    'title' => '15 Minutes Physical Movement',
                    'title_hi' => '15 मिनट शारीरिक व्यायाम',
                    'description' => 'Brisk walk, bodyweight mobility, or stretching.',
                    'description_hi' => 'तेज़ चाल, हल्का व्यायाम या स्ट्रेचिंग करें।',
                    'task_type' => 'duration_timer',
                    'target_value' => 15,
                    'is_recovery_day' => false,
                    'xp_reward' => 25,
                ]);
            }
        }
    }

    private function seed90DayTransformation(): void
    {
        $template = ChallengeTemplate::updateOrCreate(
            ['slug' => '90-day-transformation'],
            [
                'title' => '90-Day Full Transformation',
                'title_hi' => '90-दिवसीय पूर्ण रूपांतरण',
                'description' => 'Phase 1: Reset (1-30), Phase 2: Build (31-60), Phase 3: Lock-In (61-90). Total life overhaul.',
                'description_hi' => 'चरण 1: रीसेट (1-30), चरण 2: निर्माण (31-60), चरण 3: दृढ़ता (61-90)। जीवन का संपूर्ण कायाकल्प।',
                'duration_days' => 90,
                'difficulty' => 'intermediate',
                'category' => 'transformation',
                'is_active' => true,
            ]
        );

        for ($day = 1; $day <= 90; $day++) {
            $phase = $day <= 30 ? 'Reset' : ($day <= 60 ? 'Build' : 'Lock-In');

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => "Day $day [$phase]: Circadian Sleep Anchor",
                'title_hi' => "दिन $day [$phase]: समय पर नींद और जागरण",
                'description' => 'In bed by 23:00 PM. No phone screens 45 minutes before sleeping.',
                'description_hi' => 'रात 11 बजे तक बिस्तर पर जाएं। सोने से 45 मिनट पहले स्क्रीन बंद रखें।',
                'task_type' => 'boolean',
                'target_value' => 1,
                'is_recovery_day' => false,
                'xp_reward' => 25,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => "Day $day [$phase]: 45m Focused Execution Block",
                'title_hi' => "दिन $day [$phase]: 45 मिनट का गहरा ध्यान सत्र",
                'description' => 'Complete a deep work session with distracting apps blocked.',
                'description_hi' => 'ध्यान भटकाने वाले ऐप्स बंद रखकर 45 मिनट का कार्य पूरा करें।',
                'task_type' => 'duration_timer',
                'target_value' => 45,
                'is_recovery_day' => false,
                'xp_reward' => 35,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => "Day $day [$phase]: Whole Food Nutrition & 3L Water",
                'title_hi' => "दिन $day [$phase]: शुद्ध पोषण और 3 लीटर पानी",
                'description' => 'Zero carbonated sugary drinks; hit 3.0L water intake target.',
                'description_hi' => 'मीठे पेय पदार्थों से बचें; 3 लीटर पानी का लक्ष्य पूरा करें।',
                'task_type' => 'numeric_counter',
                'target_value' => 3000,
                'is_recovery_day' => false,
                'xp_reward' => 25,
            ]);
        }
    }

    private function seedSummerArc(): void
    {
        $template = ChallengeTemplate::updateOrCreate(
            ['slug' => 'summer-arc'],
            [
                'title' => 'Summer Arc',
                'title_hi' => 'समर आर्क (Summer Arc)',
                'description' => '60 Days of vitality, aesthetic fitness, radiant skincare, hydration, and skill acquisition.',
                'description_hi' => '60 दिनों में ऊर्जा, शारीरिक सौष्ठव, त्वचा की देखभाल, भरपूर पानी और नए कौशल।',
                'duration_days' => 60,
                'difficulty' => 'intermediate',
                'category' => 'summer_arc',
                'is_active' => true,
            ]
        );

        for ($day = 1; $day <= 60; $day++) {
            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Hydration Engine: 3.5L Water',
                'title_hi' => 'भरपूर पानी: 3.5 लीटर',
                'description' => 'Consistent hydration tracked throughout the day with electrolytes.',
                'description_hi' => 'दिन भर में 3.5 लीटर पानी का लक्ष्य पूरा करें।',
                'task_type' => 'numeric_counter',
                'target_value' => 3500,
                'is_recovery_day' => false,
                'xp_reward' => 25,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Morning Solar Priming (15 mins)',
                'title_hi' => 'सुबह 15 मिनट धूप लें',
                'description' => 'Direct morning sunlight before 08:30 AM to set circadian rhythm.',
                'description_hi' => 'सुबह 8:30 से पहले 15 मिनट धूप में बिताएं।',
                'task_type' => 'duration_timer',
                'target_value' => 15,
                'is_recovery_day' => false,
                'xp_reward' => 20,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Aesthetic Movement / Workout (45 mins)',
                'title_hi' => '45 मिनट वर्कआउट या रनिंग',
                'description' => 'Cardio, strength training, or outdoor sports session.',
                'description_hi' => '45 मिनट जिम, रनिंग या आउटडोर खेल।',
                'task_type' => 'duration_timer',
                'target_value' => 45,
                'is_recovery_day' => false,
                'xp_reward' => 40,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Skincare Protection & Clean Eating',
                'title_hi' => 'त्वचा सुरक्षा और सात्विक आहार',
                'description' => 'Apply SPF sunscreen in AM; eat fresh seasonal fruits; avoid deep fried junk.',
                'description_hi' => 'धूप से बचाव के लिए सनस्क्रीन लगाएं और तली-भुनी चीजों से परहेज करें।',
                'task_type' => 'boolean',
                'target_value' => 1,
                'is_recovery_day' => false,
                'xp_reward' => 20,
            ]);
        }
    }

    private function seedWinterArc(): void
    {
        $template = ChallengeTemplate::updateOrCreate(
            ['slug' => 'winter-arc'],
            [
                'title' => 'Winter Arc',
                'title_hi' => 'विंटर आर्क (Winter Arc - मोंक मोड)',
                'description' => '75 Days of relentless monk mode. Pre-dawn awakening, cold showers, heavy iron, 2h deep work, and urge mastery.',
                'description_hi' => '75 दिनों का कठोर अनुशासन। सुबह 5:30 बजे जागरण, ठंडे पानी से स्नान, भारी व्यायाम, 2 घंटे गहरा कार्य और इच्छाओं पर नियंत्रण।',
                'duration_days' => 75,
                'difficulty' => 'hardcore',
                'category' => 'winter_arc',
                'is_active' => true,
            ]
        );

        for ($day = 1; $day <= 75; $day++) {
            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => '05:30 AM Pre-Dawn Awakening',
                'title_hi' => 'सुबह 05:30 बजे जागरण',
                'description' => 'Feet on the floor at 05:30 AM sharp. Zero snooze.',
                'description_hi' => 'सुबह 5:30 बजे बिना अलार्म स्नूज़ किए उठें।',
                'task_type' => 'boolean',
                'target_value' => 1,
                'is_recovery_day' => false,
                'xp_reward' => 30,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => '60-Second Cold Shower Shock',
                'title_hi' => '60 सेकंड ठंडा स्नान',
                'description' => 'Elevate dopamine naturally and forge mental grit under cold water.',
                'description_hi' => 'मानसिक दृढ़ता के लिए 60 सेकंड ठंडे पानी से स्नान करें।',
                'task_type' => 'duration_timer',
                'target_value' => 1,
                'is_recovery_day' => false,
                'xp_reward' => 35,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Iron Discipline: 45-60m Heavy Lifting / Workout',
                'title_hi' => '45-60 मिनट कठोर कसरत',
                'description' => 'Progressive resistance training or high-intensity calisthenics.',
                'description_hi' => 'जिम में वजन उठाएं या कैलिस्थेनिक्स करें।',
                'task_type' => 'duration_timer',
                'target_value' => 45,
                'is_recovery_day' => false,
                'xp_reward' => 50,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => '2-Hour Distraction-Free Deep Work',
                'title_hi' => '2 घंटे का निर्बाध अध्ययन/कार्य',
                'description' => 'Engage native app blocker. Pure focus on your core craft or exam.',
                'description_hi' => 'ब्लॉकर चालू करके बिना किसी व्यवधान के 2 घंटे पढ़ाई या काम करें।',
                'task_type' => 'duration_timer',
                'target_value' => 120,
                'is_recovery_day' => false,
                'xp_reward' => 60,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => '15 Pages Physical Book Reading',
                'title_hi' => 'किताब के 15 पन्ने पढ़ें',
                'description' => 'Non-fiction, philosophy, or domain expertise book.',
                'description_hi' => 'ज्ञानवर्धक या दार्शनिक पुस्तक के 15 पृष्ठ पढ़ें।',
                'task_type' => 'numeric_counter',
                'target_value' => 15,
                'is_recovery_day' => false,
                'xp_reward' => 25,
            ]);

            ChallengeTemplateTask::create([
                'challenge_template_id' => $template->id,
                'day_number' => $day,
                'title' => 'Urge Redirection & Impulse Mastery',
                'title_hi' => 'इच्छाओं का सकारात्मक रूपांतरण',
                'description' => 'Zero doomscrolling; when urge strikes, execute 15 pushups or drink cold water.',
                'description_hi' => 'सोशल मीडिया की लत से बचें; भटकाव होने पर 15 पुशअप्स करें।',
                'task_type' => 'boolean',
                'target_value' => 1,
                'is_recovery_day' => false,
                'xp_reward' => 30,
            ]);
        }
    }
}
