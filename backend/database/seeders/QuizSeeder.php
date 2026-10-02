<?php

namespace Database\Seeders;

use App\Models\QuizOption;
use App\Models\QuizQuestion;
use Illuminate\Database\Seeder;

class QuizSeeder extends Seeder
{
    public function run(): void
    {
        $questions = [
            // Dimension 1: Sleep Architecture & Energy
            [
                'dimension' => 'sleep',
                'order_number' => 1,
                'question_en' => 'What is the very first thing you do within 5 minutes of waking up?',
                'question_hi' => 'सुबह उठने के 5 मिनट के भीतर आप सबसे पहले क्या करते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Grab phone and scroll social media / reels in bed', 'option_hi' => 'फोन उठाकर बिस्तर में ही रील्स/सोशल मीडिया देखना'],
                    ['score_points' => 2, 'option_en' => 'Hit snooze multiple times, wake up feeling foggy', 'option_hi' => 'अलार्म स्नूज़ करना और भारीपन के साथ उठना'],
                    ['score_points' => 3, 'option_en' => 'Check work messages or email while getting out of bed', 'option_hi' => 'बिस्तर से उठते हुए काम के संदेश या ईमेल देखना'],
                    ['score_points' => 4, 'option_en' => 'Drink water, get out of bed immediately without screens', 'option_hi' => 'बिना स्क्रीन देखे तुरंत पानी पीना और बिस्तर छोड़ना'],
                ],
            ],
            [
                'dimension' => 'sleep',
                'order_number' => 2,
                'question_en' => 'How consistent is your sleeping schedule?',
                'question_hi' => 'आपकी सोने की दिनचर्या कितनी नियमित है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Chaotic; sleep varies between 1:00 AM and 4:00 AM', 'option_hi' => 'पूरी तरह अनियमित (रात 1 से 4 बजे के बीच)'],
                    ['score_points' => 2, 'option_en' => 'Inconsistent; sleep late on weekends, struggle on weekdays', 'option_hi' => 'वीकेंड पर देर से और हफ्तों के दिनों में संघर्ष'],
                    ['score_points' => 3, 'option_en' => 'Moderate; sleep around midnight, wake up around 7:30 AM', 'option_hi' => 'मध्यम (रात 12 बजे सोना, सुबह 7:30 बजे उठना)'],
                    ['score_points' => 4, 'option_en' => 'Strict anchor; in bed and asleep by 22:30–23:00 every night', 'option_hi' => 'कठोर अनुशासन (रात 10:30-11:00 बजे तक सो जाना)'],
                ],
            ],
            [
                'dimension' => 'sleep',
                'order_number' => 3,
                'question_en' => 'How do your physical energy levels feel at 2:00 PM in the afternoon?',
                'question_hi' => 'दोपहर 2:00 बजे आपकी ऊर्जा का स्तर कैसा रहता है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Completely drained; severe brain fog, need sugar or caffeine', 'option_hi' => 'पूरी तरह सुस्त, भारीपन और चाय/कॉफी की सख्त तलब'],
                    ['score_points' => 2, 'option_en' => 'Sluggish; struggle to concentrate on deep tasks', 'option_hi' => 'धीमापन, जरूरी काम में ध्यान लगाने में कठिनाई'],
                    ['score_points' => 3, 'option_en' => 'Stable enough to continue routine work', 'option_hi' => 'सामान्य, सामान्य कार्य करने योग्य ऊर्जा'],
                    ['score_points' => 4, 'option_en' => 'High alertness, crisp cognitive focus, zero crash', 'option_hi' => 'सजगता से भरपूर, स्पष्ट सोच और कोई थकान नहीं'],
                ],
            ],
            [
                'dimension' => 'sleep',
                'order_number' => 4,
                'question_en' => 'When do you stop looking at illuminated screens before sleeping?',
                'question_hi' => 'सोने से कितनी देर पहले आप स्क्रीन देखना बंद करते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Phone is in my hand right until my eyes shut', 'option_hi' => 'आंखें बंद होने तक फोन हाथ में रहता है'],
                    ['score_points' => 2, 'option_en' => 'Within 15 minutes of sleeping', 'option_hi' => 'सोने के 15 मिनट पहले तक'],
                    ['score_points' => 3, 'option_en' => 'About 30–45 minutes prior', 'option_hi' => 'लगभग 30 से 45 मिनट पहले'],
                    ['score_points' => 4, 'option_en' => 'At least 60 minutes before bed; phone stays outside bedroom', 'option_hi' => 'कम से कम 60 मिनट पहले; फोन कमरे से बाहर रहता है'],
                ],
            ],

            // Dimension 2: Digital Distraction & Attention Span
            [
                'dimension' => 'digital',
                'order_number' => 5,
                'question_en' => 'What does your typical daily smartphone screen time look like?',
                'question_hi' => 'आपका दैनिक स्मार्टफोन स्क्रीन समय आमतौर पर कितना होता है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => '7+ hours per day, mostly Instagram, YouTube, reels', 'option_hi' => '7+ घंटे प्रतिदिन (ज्यादातर रील्स और शॉर्ट्स)'],
                    ['score_points' => 2, 'option_en' => '5 to 7 hours per day', 'option_hi' => '5 से 7 घंटे प्रतिदिन'],
                    ['score_points' => 3, 'option_en' => '3 to 5 hours per day', 'option_hi' => '3 से 5 घंटे प्रतिदिन'],
                    ['score_points' => 4, 'option_en' => 'Under 3 hours per day, strictly intentional utility', 'option_hi' => '3 घंटे से कम, केवल जरूरी काम के लिए'],
                ],
            ],
            [
                'dimension' => 'digital',
                'order_number' => 6,
                'question_en' => 'When you sit down to study or do complex work, how long before you check your phone?',
                'question_hi' => 'पढ़ाई या काम करते समय कितनी देर में आपका ध्यान फोन पर जाता है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Less than 10 minutes; open apps without realizing', 'option_hi' => '10 मिनट से कम; बिना सोचे-समझे ऐप खोल लेना'],
                    ['score_points' => 2, 'option_en' => 'About 20 to 25 minutes before feeling restless', 'option_hi' => '20 से 25 मिनट बाद बेचैनी महसूस होना'],
                    ['score_points' => 3, 'option_en' => 'Around 45 to 60 minutes of uninterrupted work', 'option_hi' => '45 से 60 मिनट तक ध्यान केंद्रित रहना'],
                    ['score_points' => 4, 'option_en' => '90+ minutes of deep flow state without touching devices', 'option_hi' => '90+ मिनट तक बिना फोन छुए गहरा काम करना'],
                ],
            ],
            [
                'dimension' => 'digital',
                'order_number' => 7,
                'question_en' => 'How do you respond to boredom (waiting in a queue or elevator)?',
                'question_hi' => 'अकेले या खाली समय में (कतार में या लिफ्ट में) आप क्या करते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Instant phone pull; cannot stand 30 seconds of quiet', 'option_hi' => 'तुरंत फोन निकालना; 30 सेकंड भी शांत नहीं बैठ पाना'],
                    ['score_points' => 2, 'option_en' => 'Usually take out phone to pass time', 'option_hi' => 'अक्सर समय काटने के लिए फोन निकालना'],
                    ['score_points' => 3, 'option_en' => 'Occasionally check phone, but can observe surroundings', 'option_hi' => 'कभी-कभी देखना, लेकिन आसपास भी ध्यान देना'],
                    ['score_points' => 4, 'option_en' => 'Comfortable with stillness; zero urge to consume digital noise', 'option_hi' => 'शांत रहने में सहज; फोन देखने की कोई हड़बड़ी नहीं'],
                ],
            ],
            [
                'dimension' => 'digital',
                'order_number' => 8,
                'question_en' => 'How frequently do you feel regret or self-criticism after closing social media?',
                'question_hi' => 'सोशल मीडिया बंद करने के बाद आपको समय बर्बादी का पछतावा कितनी बार होता है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Daily; feeling like hours vanished with nothing to show', 'option_hi' => 'रोजाना; घंटों बर्बाद होने का भारी पछतावा'],
                    ['score_points' => 2, 'option_en' => 'Several times a week', 'option_hi' => 'सप्ताह में कई बार'],
                    ['score_points' => 3, 'option_en' => 'Rarely; I consume mostly educational media', 'option_hi' => 'शायद ही कभी'],
                    ['score_points' => 4, 'option_en' => 'Never; my digital consumption is completely curated', 'option_hi' => 'कभी नहीं; मेरा डिजिटल उपयोग पूरी तरह नियंत्रित है'],
                ],
            ],

            // Dimension 3: Physical Health & Movement
            [
                'dimension' => 'physical',
                'order_number' => 9,
                'question_en' => 'How much intentional physical movement/exercise do you get weekly?',
                'question_hi' => 'सप्ताह में आप कितना व्यायाम या शारीरिक श्रम करते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Virtually zero; purely sedentary lifestyle', 'option_hi' => 'लगभग शून्य; पूरी तरह निष्क्रिय जीवनशैली'],
                    ['score_points' => 2, 'option_en' => '1 or 2 random walks or irregular workouts per month', 'option_hi' => 'महीने में 1-2 बार अनियमित व्यायाम या सैर'],
                    ['score_points' => 3, 'option_en' => '2 to 3 workout sessions or 7,000+ daily steps', 'option_hi' => 'सप्ताह में 2-3 दिन व्यायाम या 7,000+ कदम'],
                    ['score_points' => 4, 'option_en' => '4 to 6 structured workout/sport sessions per week', 'option_hi' => 'सप्ताह में 4-6 दिन नियमित कसरत या खेल'],
                ],
            ],
            [
                'dimension' => 'physical',
                'order_number' => 10,
                'question_en' => 'What is your daily water consumption pattern?',
                'question_hi' => 'आप रोजाना कितना पानी पीते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Less than 1 Liter; only drink when parched', 'option_hi' => '1 लीटर से कम; केवल प्यास लगने पर ही पीना'],
                    ['score_points' => 2, 'option_en' => '1 to 2 Liters; forget to hydrate during work', 'option_hi' => '1 से 2 लीटर; काम के दौरान पानी भूल जाना'],
                    ['score_points' => 3, 'option_en' => '2 to 3 Liters consistently', 'option_hi' => '2 से 3 लीटर नियमित रूप से'],
                    ['score_points' => 4, 'option_en' => '3.5+ Liters daily with electrolytes tracking', 'option_hi' => '3.5+ लीटर प्रतिदिन अनुशासन के साथ'],
                ],
            ],
            [
                'dimension' => 'physical',
                'order_number' => 11,
                'question_en' => 'What best describes your nutritional choices over the past 30 days?',
                'question_hi' => 'पिछले 30 दिनों में आपका खान-पान कैसा रहा है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Frequent fast food, late-night ordering, sugary drinks', 'option_hi' => 'जंक फूड, देर रात ऑर्डर करना, कोल्ड ड्रिंक्स'],
                    ['score_points' => 2, 'option_en' => 'Home meals mixed with frequent junk snacking', 'option_hi' => 'घर का खाना लेकिन साथ में बार-बार नमकीन/बिस्कुट'],
                    ['score_points' => 3, 'option_en' => 'Balanced home meals, moderate protein, occasional treats', 'option_hi' => 'संतुलित घर का भोजन और पर्याप्त प्रोटीन'],
                    ['score_points' => 4, 'option_en' => 'High whole-food density, clean hydration, zero junk', 'option_hi' => 'शुद्ध प्राकृतिक भोजन, भरपूर पोषण, शून्य जंक'],
                ],
            ],
            [
                'dimension' => 'physical',
                'order_number' => 12,
                'question_en' => 'How much direct outdoor sunlight hits your eyes in the morning?',
                'question_hi' => 'सुबह के समय आपको कितनी सीधी धूप मिलती है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Zero; stay indoors under artificial LED lighting', 'option_hi' => 'शून्य; दिनभर कमरे के अंदर ट्यूबलाइट में रहना'],
                    ['score_points' => 2, 'option_en' => 'Less than 5 minutes during daily commute', 'option_hi' => 'आने-जाने के दौरान 5 मिनट से कम'],
                    ['score_points' => 3, 'option_en' => '10 to 15 minutes most mornings', 'option_hi' => 'अधिकांश सुबह 10 से 15 मिनट'],
                    ['score_points' => 4, 'option_en' => '20+ minutes of morning outdoor exposure daily', 'option_hi' => 'प्रतिदिन 20+ मिनट सुबह की ताजी धूप'],
                ],
            ],

            // Dimension 4: Mental Discipline & Purpose
            [
                'dimension' => 'mindset',
                'order_number' => 13,
                'question_en' => 'When you make a commitment to yourself (e.g., "Starting Monday"), what happens?',
                'question_hi' => 'जब आप कोई संकल्प लेते हैं (जैसे "सोमवार से शुरू"), तो क्या होता है?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'I break it within 3 days and feel demoralized', 'option_hi' => '3 दिन में टूट जाता है और निराशा होती है'],
                    ['score_points' => 2, 'option_en' => 'I last about a week, then drop off when friction appears', 'option_hi' => 'एक सप्ताह चलता है, फिर आलस आ जाता है'],
                    ['score_points' => 3, 'option_en' => 'I maintain it for 2 to 3 weeks before losing steam', 'option_hi' => '2-3 सप्ताह तक टिका रहता है'],
                    ['score_points' => 4, 'option_en' => 'I follow through consistently, adapting to challenges', 'option_hi' => 'लगातार पालन करता हूं और रुकावटों से पार पाता हूं'],
                ],
            ],
            [
                'dimension' => 'mindset',
                'order_number' => 14,
                'question_en' => 'How do you handle high-dopamine urges (scrolling, adult content, junk food)?',
                'question_hi' => 'तीव्र इच्छाओं (रील्स, पोर्न, जंक फूड) का सामना करने पर आपकी प्रतिक्रिया?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Immediate surrender; almost zero impulse resistance', 'option_hi' => 'तुरंत हार मान लेना; शून्य आत्म-नियंत्रण'],
                    ['score_points' => 2, 'option_en' => 'Resist briefly, but give in after short mental debate', 'option_hi' => 'थोड़ा रुकना, लेकिन जल्दी ही समर्पण कर देना'],
                    ['score_points' => 3, 'option_en' => 'Can redirect urges about 60% of the time', 'option_hi' => '60% मामलों में ध्यान भटकाने में सफल होना'],
                    ['score_points' => 4, 'option_en' => 'Complete emotional control; high mastery over dopamine impulses', 'option_hi' => 'पूर्ण मानसिक नियंत्रण; इच्छाओं का स्वस्थ रूपांतरण'],
                ],
            ],
            [
                'dimension' => 'mindset',
                'order_number' => 15,
                'question_en' => 'How many pages of non-fiction or educational literature do you read weekly?',
                'question_hi' => 'सप्ताह में आप ज्ञानवर्धक या उपयोगी पुस्तकों के कितने पृष्ठ पढ़ते हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Zero pages; haven\'t read a book in months/years', 'option_hi' => 'शून्य; महीनों से कोई पुस्तक नहीं पढ़ी'],
                    ['score_points' => 2, 'option_en' => 'Skim articles or Twitter threads, but no books', 'option_hi' => 'सिर्फ लेख या सोशल पोस्ट पढ़ना, किताबें नहीं'],
                    ['score_points' => 3, 'option_en' => 'Read 10 to 25 pages per week', 'option_hi' => 'सप्ताह में 10 से 25 पन्ने'],
                    ['score_points' => 4, 'option_en' => '50+ pages per week consistently', 'option_hi' => 'सप्ताह में 50+ पन्ने निरंतर'],
                ],
            ],
            [
                'dimension' => 'mindset',
                'order_number' => 16,
                'question_en' => 'How clear are your 90-day personal and professional goals right now?',
                'question_hi' => 'अगले 90 दिनों के आपके व्यक्तिगत और करियर लक्ष्य कितने स्पष्ट हैं?',
                'options' => [
                    ['score_points' => 1, 'option_en' => 'Completely unclear; feeling lost and floating day to day', 'option_hi' => 'बिल्कुल अस्पष्ट; दिशाहीन महसूस होना'],
                    ['score_points' => 2, 'option_en' => 'Vague ideas in my head, but nothing written or tracked', 'option_hi' => 'मन में धुंधले विचार, पर कहीं लिखे या मापे नहीं'],
                    ['score_points' => 3, 'option_en' => 'General milestones identified, execution inconsistent', 'option_hi' => 'लक्ष्य तय हैं, लेकिन क्रियान्वयन में कमी है'],
                    ['score_points' => 4, 'option_en' => 'Crystal clear, written, reviewed weekly, daily actions defined', 'option_hi' => 'एकदम स्पष्ट, लिखित, और दैनिक कार्यों में विभाजित'],
                ],
            ],
        ];

        foreach ($questions as $qData) {
            $question = QuizQuestion::create([
                'dimension' => $qData['dimension'],
                'order_number' => $qData['order_number'],
                'question_en' => $qData['question_en'],
                'question_hi' => $qData['question_hi'],
            ]);

            foreach ($qData['options'] as $opt) {
                QuizOption::create([
                    'quiz_question_id' => $question->id,
                    'score_points' => $opt['score_points'],
                    'option_en' => $opt['option_en'],
                    'option_hi' => $opt['option_hi'],
                ]);
            }
        }
    }
}
