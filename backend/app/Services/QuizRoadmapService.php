<?php

namespace App\Services;

use App\Models\QuizAnswer;
use App\Models\QuizAttempt;
use App\Models\QuizOption;
use App\Models\QuizQuestion;
use App\Models\Roadmap;
use App\Models\RoadmapPhase;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class QuizRoadmapService
{
    /**
     * Evaluate submitted answers, create quiz attempt, and generate personalized roadmap.
     */
    public function evaluateAndGenerateRoadmap(User $user, array $answers): array
    {
        return DB::transaction(function () use ($user, $answers) {
            $totalPoints = 0;
            $processedAnswers = [];

            // 1. Calculate scores
            foreach ($answers as $item) {
                $question = QuizQuestion::find($item['question_id']);
                $option = QuizOption::find($item['option_id']);

                if (!$question || !$option) {
                    continue;
                }

                $points = (int) $option->score_points;
                $totalPoints += $points;

                $processedAnswers[] = [
                    'question_id' => $question->id,
                    'option_id' => $option->id,
                    'score' => $points,
                    'dimension' => $question->dimension,
                ];
            }

            $answersCount = max(1, count($processedAnswers));
            $maxPossibleScore = $answersCount * 4;
            $lifeBalanceIndex = round(($totalPoints / $maxPossibleScore) * 100, 2);

            // 2. Determine Recommended Tier & Challenge
            if ($lifeBalanceIndex < 40) {
                $tier = 'Dopamine Burnout';
                $challengeSlug = '21-day-habit-builder';
            } elseif ($lifeBalanceIndex < 65) {
                $tier = 'Inconsistent Seeker';
                $challengeSlug = 'summer-arc';
            } elseif ($lifeBalanceIndex < 85) {
                $tier = 'Disciplined Architect';
                $challengeSlug = 'winter-arc';
            } else {
                $tier = 'Master Ascendant';
                $challengeSlug = '90-day-transformation';
            }

            // 3. Create QuizAttempt
            $attempt = QuizAttempt::create([
                'user_id' => $user->id,
                'total_score' => $totalPoints,
                'life_balance_index' => $lifeBalanceIndex,
                'recommended_tier' => $tier,
                'completed_at' => now(),
            ]);

            // 4. Save Quiz Answers
            foreach ($processedAnswers as $ans) {
                QuizAnswer::create([
                    'quiz_attempt_id' => $attempt->id,
                    'quiz_question_id' => $ans['question_id'],
                    'quiz_option_id' => $ans['option_id'],
                    'score' => $ans['score'],
                ]);
            }

            // 5. Deactivate previous roadmaps and create new active roadmap
            Roadmap::where('user_id', $user->id)->update(['status' => 'archived']);

            $roadmap = Roadmap::create([
                'user_id' => $user->id,
                'quiz_attempt_id' => $attempt->id,
                'title' => 'Personalized Roadmap: ' . $tier,
                'tier' => $tier,
                'target_challenge_slug' => $challengeSlug,
                'status' => 'active',
            ]);

            // 6. Generate Roadmap Phases
            $phases = [
                [
                    'phase_number' => 1,
                    'title' => 'Phase 1: Foundation & Dopamine Reset',
                    'focus' => 'Eliminate late-night doomscrolling, establish consistent wake times, and hydrate upon waking.',
                    'duration_days' => 14,
                    'is_unlocked' => true,
                ],
                [
                    'phase_number' => 2,
                    'title' => 'Phase 2: Routine Solidification',
                    'focus' => 'Stack deep work blocks of 45 minutes and incorporate daily physical movement.',
                    'duration_days' => 21,
                    'is_unlocked' => false,
                ],
                [
                    'phase_number' => 3,
                    'title' => 'Phase 3: Identity & Master Discipline',
                    'focus' => 'Consolidate unbreakable identity shifts and maintain an 85%+ challenge adherence rate.',
                    'duration_days' => 30,
                    'is_unlocked' => false,
                ],
            ];

            foreach ($phases as $pData) {
                RoadmapPhase::create([
                    'roadmap_id' => $roadmap->id,
                    'phase_number' => $pData['phase_number'],
                    'title' => $pData['title'],
                    'focus' => $pData['focus'],
                    'duration_days' => $pData['duration_days'],
                    'is_unlocked' => $pData['is_unlocked'],
                ]);
            }

            return [
                'attempt' => $attempt,
                'tier' => $tier,
                'archetype' => $tier,
                'life_balance_index' => $lifeBalanceIndex,
                'target_challenge_slug' => $challengeSlug,
                'roadmap' => $roadmap->fresh('phases'),
            ];
        });
    }
}
