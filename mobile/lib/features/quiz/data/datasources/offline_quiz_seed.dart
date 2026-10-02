import '../models/quiz_models.dart';

/// Clinical 16-Question Lifestyle Transformation Seed Data for Offline-First Capability.
final List<QuizQuestionModel> offlineQuizQuestions = [
  // ---------------------------------------------------------------------------
  // Dimension 1: Sleep Architecture & Energy
  // ---------------------------------------------------------------------------
  QuizQuestionModel(
    id: 1,
    dimension: 'sleep',
    orderNumber: 1,
    questionEn: 'What is the very first thing you do within 5 minutes of waking up?',
    questionHi: 'सुबह उठने के 5 मिनट के भीतर आप सबसे पहले क्या करते हैं?',
    options: [
      QuizOptionModel(
        id: 1,
        scorePoints: 1,
        optionEn: 'Grab phone and scroll social media / reels in bed',
        optionHi: 'फोन उठाकर बिस्तर में ही रील्स/सोशल मीडिया देखना',
      ),
      QuizOptionModel(
        id: 2,
        scorePoints: 2,
        optionEn: 'Hit snooze multiple times, wake up feeling foggy',
        optionHi: 'अलार्म स्नूज़ करना और भारीपन के साथ उठना',
      ),
      QuizOptionModel(
        id: 3,
        scorePoints: 3,
        optionEn: 'Check work messages or email while getting out of bed',
        optionHi: 'बिस्तर से उठते हुए काम के संदेश या ईमेल देखना',
      ),
      QuizOptionModel(
        id: 4,
        scorePoints: 4,
        optionEn: 'Drink water, get out of bed immediately without screens',
        optionHi: 'बिना स्क्रीन देखे तुरंत पानी पीना और बिस्तर छोड़ना',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 2,
    dimension: 'sleep',
    orderNumber: 2,
    questionEn: 'How consistent is your sleeping schedule?',
    questionHi: 'आपकी सोने की दिनचर्या कितनी नियमित है?',
    options: [
      QuizOptionModel(
        id: 5,
        scorePoints: 1,
        optionEn: 'Chaotic; sleep varies between 1:00 AM and 4:00 AM',
        optionHi: 'पूरी तरह अनियमित (रात 1 से 4 बजे के बीच)',
      ),
      QuizOptionModel(
        id: 6,
        scorePoints: 2,
        optionEn: 'Inconsistent; sleep late on weekends, struggle on weekdays',
        optionHi: 'वीकेंड पर देर से और हफ्तों के दिनों में संघर्ष',
      ),
      QuizOptionModel(
        id: 7,
        scorePoints: 3,
        optionEn: 'Moderate; sleep around midnight, wake up around 7:30 AM',
        optionHi: 'मध्यम (रात 12 बजे सोना, सुबह 7:30 बजे उठना)',
      ),
      QuizOptionModel(
        id: 8,
        scorePoints: 4,
        optionEn: 'Strict anchor; in bed and asleep by 22:30–23:00 every night',
        optionHi: 'कठोर अनुशासन (रात 10:30-11:00 बजे तक सो जाना)',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 3,
    dimension: 'sleep',
    orderNumber: 3,
    questionEn: 'How do your physical energy levels feel at 2:00 PM in the afternoon?',
    questionHi: 'दोपहर 2:00 बजे आपकी ऊर्जा का स्तर कैसा रहता है?',
    options: [
      QuizOptionModel(
        id: 9,
        scorePoints: 1,
        optionEn: 'Completely drained; severe brain fog, need sugar or caffeine',
        optionHi: 'पूरी तरह सुस्त, भारीपन और चाय/कॉफी की सख्त तलब',
      ),
      QuizOptionModel(
        id: 10,
        scorePoints: 2,
        optionEn: 'Sluggish; struggle to concentrate on deep tasks',
        optionHi: 'धीमापन, जरूरी काम में ध्यान लगाने में कठिनाई',
      ),
      QuizOptionModel(
        id: 11,
        scorePoints: 3,
        optionEn: 'Stable enough to continue routine work',
        optionHi: 'सामान्य, सामान्य कार्य करने योग्य ऊर्जा',
      ),
      QuizOptionModel(
        id: 12,
        scorePoints: 4,
        optionEn: 'High alertness, crisp cognitive focus, zero crash',
        optionHi: 'सजगता से भरपूर, स्पष्ट सोच और कोई थकान नहीं',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 4,
    dimension: 'sleep',
    orderNumber: 4,
    questionEn: 'When do you stop looking at illuminated screens before sleeping?',
    questionHi: 'सोने से कितनी देर पहले आप स्क्रीन देखना बंद करते हैं?',
    options: [
      QuizOptionModel(
        id: 13,
        scorePoints: 1,
        optionEn: 'Phone is in my hand right until my eyes shut',
        optionHi: 'आंखें बंद होने तक फोन हाथ में रहता है',
      ),
      QuizOptionModel(
        id: 14,
        scorePoints: 2,
        optionEn: 'Within 15 minutes of sleeping',
        optionHi: 'सोने के 15 मिनट पहले तक',
      ),
      QuizOptionModel(
        id: 15,
        scorePoints: 3,
        optionEn: 'About 30–45 minutes prior',
        optionHi: 'लगभग 30 से 45 मिनट पहले',
      ),
      QuizOptionModel(
        id: 16,
        scorePoints: 4,
        optionEn: 'At least 60 minutes before bed; phone stays outside bedroom',
        optionHi: 'कम से कम 60 मिनट पहले; फोन कमरे से बाहर रहता है',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  // Dimension 2: Digital Distraction & Attention Span
  // ---------------------------------------------------------------------------
  QuizQuestionModel(
    id: 5,
    dimension: 'digital',
    orderNumber: 5,
    questionEn: 'What does your typical daily smartphone screen time look like?',
    questionHi: 'आपका दैनिक स्मार्टफोन स्क्रीन समय आमतौर पर कितना होता है?',
    options: [
      QuizOptionModel(
        id: 17,
        scorePoints: 1,
        optionEn: '7+ hours per day, mostly Instagram, YouTube, reels',
        optionHi: '7+ घंटे प्रतिदिन (ज्यादातर रील्स और शॉर्ट्स)',
      ),
      QuizOptionModel(
        id: 18,
        scorePoints: 2,
        optionEn: '5 to 7 hours per day',
        optionHi: '5 से 7 घंटे प्रतिदिन',
      ),
      QuizOptionModel(
        id: 19,
        scorePoints: 3,
        optionEn: '3 to 5 hours per day',
        optionHi: '3 से 5 घंटे प्रतिदिन',
      ),
      QuizOptionModel(
        id: 20,
        scorePoints: 4,
        optionEn: 'Under 3 hours per day, strictly intentional utility',
        optionHi: '3 घंटे से कम, केवल जरूरी काम के लिए',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 6,
    dimension: 'digital',
    orderNumber: 6,
    questionEn: 'When you sit down to study or do complex work, how long before you check your phone?',
    questionHi: 'पढ़ाई या काम करते समय कितनी देर में आपका ध्यान फोन पर जाता है?',
    options: [
      QuizOptionModel(
        id: 21,
        scorePoints: 1,
        optionEn: 'Less than 10 minutes; open apps without realizing',
        optionHi: '10 मिनट से कम; बिना सोचे-समझे ऐप खोल लेना',
      ),
      QuizOptionModel(
        id: 22,
        scorePoints: 2,
        optionEn: 'About 20 to 25 minutes before feeling restless',
        optionHi: '20 से 25 मिनट बाद बेचैनी महसूस होना',
      ),
      QuizOptionModel(
        id: 23,
        scorePoints: 3,
        optionEn: 'Around 45 to 60 minutes of uninterrupted work',
        optionHi: '45 से 60 मिनट तक ध्यान केंद्रित रहना',
      ),
      QuizOptionModel(
        id: 24,
        scorePoints: 4,
        optionEn: '90+ minutes of deep flow state without touching devices',
        optionHi: '90+ मिनट तक बिना फोन छुए गहरा काम करना',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 7,
    dimension: 'digital',
    orderNumber: 7,
    questionEn: 'How do you respond to boredom (waiting in a queue or elevator)?',
    questionHi: 'अकेले या खाली समय में (कतार में या लिफ्ट में) आप क्या करते हैं?',
    options: [
      QuizOptionModel(
        id: 25,
        scorePoints: 1,
        optionEn: 'Instant phone pull; cannot stand 30 seconds of quiet',
        optionHi: 'तुरंत फोन निकालना; 30 सेकंड भी शांत नहीं बैठ पाना',
      ),
      QuizOptionModel(
        id: 26,
        scorePoints: 2,
        optionEn: 'Usually take out phone to pass time',
        optionHi: 'अक्सर समय काटने के लिए फोन निकालना',
      ),
      QuizOptionModel(
        id: 27,
        scorePoints: 3,
        optionEn: 'Occasionally check phone, but can observe surroundings',
        optionHi: 'कभी-कभी देखना, लेकिन आसपास भी ध्यान देना',
      ),
      QuizOptionModel(
        id: 28,
        scorePoints: 4,
        optionEn: 'Comfortable with stillness; zero urge to consume digital noise',
        optionHi: 'शांत रहने में सहज; फोन देखने की कोई हड़बड़ी नहीं',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 8,
    dimension: 'digital',
    orderNumber: 8,
    questionEn: 'How frequently do you feel regret or self-criticism after closing social media?',
    questionHi: 'सोशल मीडिया बंद करने के बाद आपको समय बर्बादी का पछतावा कितनी बार होता है?',
    options: [
      QuizOptionModel(
        id: 29,
        scorePoints: 1,
        optionEn: 'Daily; feeling like hours vanished with nothing to show',
        optionHi: 'रोजाना; घंटों बर्बाद होने का भारी पछतावा',
      ),
      QuizOptionModel(
        id: 30,
        scorePoints: 2,
        optionEn: 'Several times a week',
        optionHi: 'सप्ताह में कई बार',
      ),
      QuizOptionModel(
        id: 31,
        scorePoints: 3,
        optionEn: 'Rarely; I consume mostly educational media',
        optionHi: 'शायद ही कभी',
      ),
      QuizOptionModel(
        id: 32,
        scorePoints: 4,
        optionEn: 'Never; my digital consumption is completely curated',
        optionHi: 'कभी नहीं; मेरा डिजिटल उपयोग पूरी तरह नियंत्रित है',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  // Dimension 3: Physical Health & Movement
  // ---------------------------------------------------------------------------
  QuizQuestionModel(
    id: 9,
    dimension: 'physical',
    orderNumber: 9,
    questionEn: 'How much intentional physical movement/exercise do you get weekly?',
    questionHi: 'सप्ताह में आप कितना व्यायाम या शारीरिक श्रम करते हैं?',
    options: [
      QuizOptionModel(
        id: 33,
        scorePoints: 1,
        optionEn: 'Virtually zero; purely sedentary lifestyle',
        optionHi: 'लगभग शून्य; पूरी तरह निष्क्रिय जीवनशैली',
      ),
      QuizOptionModel(
        id: 34,
        scorePoints: 2,
        optionEn: '1 or 2 random walks or irregular workouts per month',
        optionHi: 'महीने में 1-2 बार अनियमित व्यायाम या सैर',
      ),
      QuizOptionModel(
        id: 35,
        scorePoints: 3,
        optionEn: '2 to 3 workout sessions or 7,000+ daily steps',
        optionHi: 'सप्ताह में 2-3 दिन व्यायाम या 7,000+ कदम',
      ),
      QuizOptionModel(
        id: 36,
        scorePoints: 4,
        optionEn: '4 to 6 structured workout/sport sessions per week',
        optionHi: 'सप्ताह में 4-6 दिन नियमित कसरत या खेल',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 10,
    dimension: 'physical',
    orderNumber: 10,
    questionEn: 'What is your daily water consumption pattern?',
    questionHi: 'आप रोजाना कितना पानी पीते हैं?',
    options: [
      QuizOptionModel(
        id: 37,
        scorePoints: 1,
        optionEn: 'Less than 1 Liter; only drink when parched',
        optionHi: '1 लीटर से कम; केवल प्यास लगने पर ही पीना',
      ),
      QuizOptionModel(
        id: 38,
        scorePoints: 2,
        optionEn: '1 to 2 Liters; forget to hydrate during work',
        optionHi: '1 से 2 लीटर; काम के दौरान पानी भूल जाना',
      ),
      QuizOptionModel(
        id: 39,
        scorePoints: 3,
        optionEn: '2 to 3 Liters consistently',
        optionHi: '2 से 3 लीटर नियमित रूप से',
      ),
      QuizOptionModel(
        id: 40,
        scorePoints: 4,
        optionEn: '3.5+ Liters daily with electrolytes tracking',
        optionHi: '3.5+ लीटर प्रतिदिन अनुशासन के साथ',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 11,
    dimension: 'physical',
    orderNumber: 11,
    questionEn: 'What best describes your nutritional choices over the past 30 days?',
    questionHi: 'पिछले 30 दिनों में आपका खान-पान कैसा रहा है?',
    options: [
      QuizOptionModel(
        id: 41,
        scorePoints: 1,
        optionEn: 'Frequent fast food, late-night ordering, sugary drinks',
        optionHi: 'जंक फूड, देर रात ऑर्डर करना, कोल्ड ड्रिंक्स',
      ),
      QuizOptionModel(
        id: 42,
        scorePoints: 2,
        optionEn: 'Home meals mixed with frequent junk snacking',
        optionHi: 'घर का खाना लेकिन साथ में बार-बार नमकीन/बिस्कुट',
      ),
      QuizOptionModel(
        id: 43,
        scorePoints: 3,
        optionEn: 'Balanced home meals, moderate protein, occasional treats',
        optionHi: 'संतुलित घर का भोजन और पर्याप्त प्रोटीन',
      ),
      QuizOptionModel(
        id: 44,
        scorePoints: 4,
        optionEn: 'High whole-food density, clean hydration, zero junk',
        optionHi: 'शुद्ध प्राकृतिक भोजन, भरपूर पोषण, शून्य जंक',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 12,
    dimension: 'physical',
    orderNumber: 12,
    questionEn: 'How much direct outdoor sunlight hits your eyes in the morning?',
    questionHi: 'सुबह के समय आपको कितनी सीधी धूप मिलती है?',
    options: [
      QuizOptionModel(
        id: 45,
        scorePoints: 1,
        optionEn: 'Zero; stay indoors under artificial LED lighting',
        optionHi: 'शून्य; दिनभर कमरे के अंदर ट्यूबलाइट में रहना',
      ),
      QuizOptionModel(
        id: 46,
        scorePoints: 2,
        optionEn: 'Less than 5 minutes during daily commute',
        optionHi: 'आने-जाने के दौरान 5 मिनट से कम',
      ),
      QuizOptionModel(
        id: 47,
        scorePoints: 3,
        optionEn: '10 to 15 minutes most mornings',
        optionHi: 'अधिकांश सुबह 10 से 15 मिनट',
      ),
      QuizOptionModel(
        id: 48,
        scorePoints: 4,
        optionEn: '20+ minutes of morning outdoor exposure daily',
        optionHi: 'प्रतिदिन 20+ मिनट सुबह की ताजी धूप',
      ),
    ],
  ),

  // ---------------------------------------------------------------------------
  // Dimension 4: Mental Discipline & Purpose
  // ---------------------------------------------------------------------------
  QuizQuestionModel(
    id: 13,
    dimension: 'mindset',
    orderNumber: 13,
    questionEn: 'When you make a commitment to yourself (e.g., "Starting Monday"), what happens?',
    questionHi: 'जब आप कोई संकल्प लेते हैं (जैसे "सोमवार से शुरू"), तो क्या होता है?',
    options: [
      QuizOptionModel(
        id: 49,
        scorePoints: 1,
        optionEn: 'I break it within 3 days and feel demoralized',
        optionHi: '3 दिन में टूट जाता है और निराशा होती है',
      ),
      QuizOptionModel(
        id: 50,
        scorePoints: 2,
        optionEn: 'I last about a week, then drop off when friction appears',
        optionHi: 'एक सप्ताह चलता है, फिर आलस आ जाता है',
      ),
      QuizOptionModel(
        id: 51,
        scorePoints: 3,
        optionEn: 'I maintain it for 2 to 3 weeks before losing steam',
        optionHi: '2-3 सप्ताह तक टिका रहता है',
      ),
      QuizOptionModel(
        id: 52,
        scorePoints: 4,
        optionEn: 'I follow through consistently, adapting to challenges',
        optionHi: 'लगातार पालन करता हूं और रुकावटों से पार पाता हूं',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 14,
    dimension: 'mindset',
    orderNumber: 14,
    questionEn: 'How do you handle high-dopamine urges (scrolling, adult content, junk food)?',
    questionHi: 'तीव्र इच्छाओं (रील्स, पोर्न, जंक फूड) का सामना करने पर आपकी प्रतिक्रिया?',
    options: [
      QuizOptionModel(
        id: 53,
        scorePoints: 1,
        optionEn: 'Immediate surrender; almost zero impulse resistance',
        optionHi: 'तुरंत हार मान लेना; शून्य आत्म-नियंत्रण',
      ),
      QuizOptionModel(
        id: 54,
        scorePoints: 2,
        optionEn: 'Resist briefly, but give in after short mental debate',
        optionHi: 'थोड़ा रुकना, लेकिन जल्दी ही समर्पण कर देना',
      ),
      QuizOptionModel(
        id: 55,
        scorePoints: 3,
        optionEn: 'Can redirect urges about 60% of the time',
        optionHi: '60% मामलों में ध्यान भटकाने में सफल होना',
      ),
      QuizOptionModel(
        id: 56,
        scorePoints: 4,
        optionEn: 'Complete emotional control; high mastery over dopamine impulses',
        optionHi: 'पूर्ण मानसिक नियंत्रण; इच्छाओं का स्वस्थ रूपांतरण',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 15,
    dimension: 'mindset',
    orderNumber: 15,
    questionEn: 'How many pages of non-fiction or educational literature do you read weekly?',
    questionHi: 'सप्ताह में आप ज्ञानवर्धक या उपयोगी पुस्तकों के कितने पृष्ठ पढ़ते हैं?',
    options: [
      QuizOptionModel(
        id: 57,
        scorePoints: 1,
        optionEn: 'Zero pages; haven\'t read a book in months/years',
        optionHi: 'शून्य; महीनों से कोई पुस्तक नहीं पढ़ी',
      ),
      QuizOptionModel(
        id: 58,
        scorePoints: 2,
        optionEn: 'Skim articles or Twitter threads, but no books',
        optionHi: 'सिर्फ लेख या सोशल पोस्ट पढ़ना, किताबें नहीं',
      ),
      QuizOptionModel(
        id: 59,
        scorePoints: 3,
        optionEn: 'Read 10 to 25 pages per week',
        optionHi: 'सप्ताह में 10 से 25 पन्ने',
      ),
      QuizOptionModel(
        id: 60,
        scorePoints: 4,
        optionEn: '50+ pages per week consistently',
        optionHi: 'सप्ताह में 50+ पन्ने निरंतर',
      ),
    ],
  ),
  QuizQuestionModel(
    id: 16,
    dimension: 'mindset',
    orderNumber: 16,
    questionEn: 'How clear are your 90-day personal and professional goals right now?',
    questionHi: 'अगले 90 दिनों के आपके व्यक्तिगत और करियर लक्ष्य कितने स्पष्ट हैं?',
    options: [
      QuizOptionModel(
        id: 61,
        scorePoints: 1,
        optionEn: 'Completely unclear; feeling lost and floating day to day',
        optionHi: 'बिल्कुल अस्पष्ट; दिशाहीन महसूस होना',
      ),
      QuizOptionModel(
        id: 62,
        scorePoints: 2,
        optionEn: 'Vague ideas in my head, but nothing written or tracked',
        optionHi: 'मन में धुंधले विचार, पर कहीं लिखे या मापे नहीं',
      ),
      QuizOptionModel(
        id: 63,
        scorePoints: 3,
        optionEn: 'General milestones identified, execution inconsistent',
        optionHi: 'लक्ष्य तय हैं, लेकिन क्रियान्वयन में कमी है',
      ),
      QuizOptionModel(
        id: 64,
        scorePoints: 4,
        optionEn: 'Crystal clear, written, reviewed weekly, daily actions defined',
        optionHi: 'एकदम स्पष्ट, लिखित, और दैनिक कार्यों में विभाजित',
      ),
    ],
  ),
];
