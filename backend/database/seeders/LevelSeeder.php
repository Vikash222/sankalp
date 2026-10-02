<?php

namespace Database\Seeders;

use App\Models\Level;
use Illuminate\Database\Seeder;

class LevelSeeder extends Seeder
{
    public function run(): void
    {
        $levelTitles = [
            1 => ['Novice', 'आरंभकर्ता'],
            2 => ['Seeker', 'जिज्ञासु'],
            3 => ['Initiate', 'दीक्षित'],
            4 => ['Apprentice', 'शिष्य'],
            5 => ['Builder', 'निर्माता'],
            6 => ['Practitioner', 'अभ्यासी'],
            7 => ['Anchor', 'स्थिर'],
            8 => ['Disciplined', 'अनुशासित'],
            9 => ['Iron Will', 'दृढ़ संकल्पी'],
            10 => ['Habit Craftsman', 'आदत शिल्पी'],
            11 => ['Vanguard', 'अग्रदूत'],
            12 => ['Sentinel', 'प्रहरी'],
            13 => ['Momentum Engine', 'गतिशीलता इंजन'],
            14 => ['Focus Keeper', 'एकाग्र रक्षक'],
            15 => ['Warrior of Dawn', 'उषा योद्धा'],
            16 => ['Shield Bearer', 'ढाल धारक'],
            17 => ['Resilient Mind', 'अडिग मन'],
            18 => ['Titan Initiate', 'महाबली आरंभक'],
            19 => ['Steadfast Spirit', 'अटल आत्मा'],
            20 => ['Master Practitioner', 'मुख्य अभ्यासी'],
            21 => ['Overcomer', 'विजयी'],
            22 => ['Phoenix', 'पुनर्जीवित फीनिक्स'],
            23 => ['Stoic Blade', 'धैर्यवान खड्ग'],
            24 => ['Iron Core', 'लौह स्तंभ'],
            25 => ['Centurion', 'शतनायक'],
            26 => ['Mind Sculptor', 'मन शिल्पी'],
            27 => ['Kinetic Force', 'गतिशील शक्ति'],
            28 => ['Cold Forged', 'शीत तप्त'],
            29 => ['Relentless Will', 'अथक संकल्प'],
            30 => ['Master of Dawn', 'उषा स्वामी'],
            31 => ['Silent Achiever', 'मौन साधक'],
            32 => ['Unstoppable', 'अप्रतिरोध्य'],
            33 => ['Deep Focus Titan', 'गहन ध्यानी'],
            34 => ['Apex Mind', 'सर्वोच्च प्रज्ञा'],
            35 => ['Sovereign Monk', 'स्वावलंबी साधक'],
            36 => ['Grand Disciplinarian', 'महान अनुशासक'],
            37 => ['Arc Commander', 'आर्क सेनापति'],
            38 => ['Iron Vanguard', 'लौह अग्रदूत'],
            39 => ['Unyielding Rock', 'अचल शिला'],
            40 => ['Ascendant', 'उन्नतात्मा'],
            41 => ['Transcendent Mind', 'दिव्य चेतना'],
            42 => ['Titan of Focus', 'एकाग्रता महाबली'],
            43 => ['Master of Arcs', 'संकल्प शिरोमणि'],
            44 => ['Prime Achiever', 'परम साधक'],
            45 => ['Sovereign Will', 'सर्वोच्च इच्छाशक्ति'],
            46 => ['Immortal Habit', 'अमर अभ्यास'],
            47 => ['Grand Architect', 'महा शिल्पी'],
            48 => ['Zenith', 'शिखर पुरुष'],
            49 => ['Legend of ArcLife', 'आर्कलाइफ कीर्तिमान'],
            50 => ['The Unbreakable', 'अजेय (The Unbreakable)'],
        ];

        for ($lvl = 1; $lvl <= 50; $lvl++) {
            $minXp = $lvl === 1 ? 0 : (int) floor(120 * pow($lvl - 1, 1.6));
            $titles = $levelTitles[$lvl] ?? ['Disciplined Warrior', 'योद्धा'];

            Level::updateOrCreate(
                ['level_number' => $lvl],
                [
                    'title' => $titles[0],
                    'title_hi' => $titles[1],
                    'min_xp' => $minXp,
                ]
            );
        }
    }
}
