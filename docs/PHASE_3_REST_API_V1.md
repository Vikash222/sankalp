# Sankalp — REST API v1 Specification & Architecture

## Overview
This document specifies the complete REST API v1 for **Sankalp**, the Android-first habit-transformation and digital-detox platform. Built with **Laravel 11 LTS**, **Sanctum**, **MySQL 8** (with SQLite local/test compatibility), and native open-source AI model abstraction.

---

## 1. Unified JSON Envelope Architecture
Every API response complies with a strict envelope:

### Success Response (`App\Http\Responses\ApiResponse::success`)
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": { ... },
  "meta": { ... } // Optional metadata, omitted if empty
}
```

### Error Response (`App\Http\Responses\ApiResponse::error`)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Validation failed for one or more fields.",
    "details": {
      "email": ["The email field must be a valid email address."]
    }
  }
}
```

### Standard Error Codes
| HTTP Status | Error Code | Description |
| :--- | :--- | :--- |
| `400` | `BAD_REQUEST` | Malformed parameters or business logic rejection |
| `401` | `UNAUTHENTICATED` | Missing or invalid Bearer token |
| `403` | `FORBIDDEN` | Access denied to the requested resource |
| `404` | `NOT_FOUND` / `RESOURCE_NOT_FOUND` | Record does not exist |
| `422` | `VALIDATION_FAILED` | Input validation rules violated |
| `500` | `SERVER_ERROR` | Internal unhandled exception |

---

## 2. API Endpoint Directory (49 Routes)

### Authentication & Identity Lifecycle (`/api/v1/auth`)
- `POST /api/v1/auth/guest`: Instant anonymous onboarding with `device_uuid`. Generates Sanctum token without asking for email or password.
- `POST /api/v1/auth/register`: Permanent email/password account creation with automatic profile, notification schedule, and initial streak creation.
- `POST /api/v1/auth/login`: Sanctum token authentication.
- `POST /api/v1/auth/upgrade`: Upgrades an anonymous guest account into a permanent email/password account without losing quiz data, habits, or streaks.
- `POST /api/v1/auth/logout`: Revokes the current Sanctum token.
- `GET /api/v1/auth/me`: Fetches authenticated user with profile and overall streak telemetry.

### User Profile & Settings (`/api/v1/user`)
- `GET /api/v1/user/profile`: Retrieves bio, height, weight, language (`en`/`hi`), theme (`day`/`dark`/`night`/`custom`), and timezone.
- `PUT /api/v1/user/profile`: Updates profile stats and preferences.
- `GET /api/v1/user/notifications/settings`: Retrieves morning, midday, evening, and bedtime notification schedules.
- `PUT /api/v1/user/notifications/settings`: Updates notification schedules and DND windows.

### Device Telemetry (`/api/v1/devices`)
- `POST /api/v1/devices/register`: Registers mobile device UUID, FCM token, platform, app version, and OS permission grants (`dnd_granted`, `usage_stats_granted`, `location_permission_status`).

### Diagnostic Quiz & Roadmaps (`/api/v1/quiz` & `/api/v1/roadmap`)
- `GET /api/v1/quiz/questions`: Returns 16 clinical lifestyle questions with Hindi & English text and 4 scored options.
- `POST /api/v1/quiz/submit`: Evaluates answers, calculates Life Balance Index ($0-100\%$), diagnoses archetype tier, and automatically generates an active Roadmap with 3 structured milestone phases.
- `GET /api/v1/roadmap/current`: Retrieves user's active personalized roadmap with unlocked and upcoming phases.

### Structured Challenges (`/api/v1/challenges`)
- `GET /api/v1/challenges/templates`: Lists available official challenges (21-Day Habit Builder, 90-Day Transformation, Summer Arc, Winter Arc).
- `GET /api/v1/challenges/templates/{id}`: Detailed curriculum syllabus and tasks.
- `POST /api/v1/challenges/start`: Enrolls user, clones curriculum tasks into `user_challenge_tasks`.
- `GET /api/v1/challenges/active`: Retrieves user's active challenge with completion percentage.
- `GET /api/v1/challenges/today`: Returns challenge tasks scheduled for the user's current day.
- `POST /api/v1/challenges/tasks/{id}/toggle`: Marks challenge task completed/uncompleted, awards XP (15 XP), evaluates daily completion bonus (50 XP), and advances challenge day.

### Habits Engine (`/api/v1/habits`)
- `GET /api/v1/habits`: Lists active user habits with today's completion status, current streak, and longest streak.
- `POST /api/v1/habits`: Creates a habit (title, category, cadence: daily/weekdays/weekly, target value, unit, reminder time).
- `GET /api/v1/habits/{id}`: Habit details.
- `PUT /api/v1/habits/{id}`: Updates habit configuration.
- `DELETE /api/v1/habits/{id}`: Archives habit.
- `POST /api/v1/habits/{id}/checkin`: Records daily check-in idempotently, advances habit streak, advances overall app streak, and awards 20 XP.
- `GET /api/v1/habits/{id}/heatmap`: Returns 365-day check-in matrix for annual habit visualization.

### Streaks & Freezes (`/api/v1/streaks`)
- `GET /api/v1/streaks/summary`: Overall streak, streak freezes available (max 2), comeback mode status, and breakdown across habits.
- `POST /api/v1/streaks/freeze/use`: Consumes a streak freeze for an emergency or sickness day.

### GPS Running / Walking / Cycling Workouts (`/api/v1/activities`)
- `GET /api/v1/activities`: Paginated activity history with date and type filters.
- `POST /api/v1/activities`: Idempotent submission using `client_uuid`:
  - **Anti-Cheat Algorithm**: Rejects superhuman speeds ($>26$ km/h running average, $>58$ km/h cycling average) and flags vehicle transit (`source = 'flagged_vehicle'`) without awarding XP or registering PRs.
  - **1km Splits**: Persists splits (`distance_m`, `duration_s`, `pace_s`, `elevation_m`).
  - **Personal Records**: Updates fastest 5K, longest distance PRs.
  - **Gamification**: Awards 10 XP per km + 20 XP workout bonus.
  - **Habit Auto-Checkin**: Automatically detects and completes matching running or workout habits!
- `GET /api/v1/activities/{id}`: Full workout details with polyline and 1km splits.
- `DELETE /api/v1/activities/{id}`: Deletes workout record.
- `GET /api/v1/activities/stats`: Aggregate weekly, monthly, and all-time distance, time, and calories.
- `GET /api/v1/activities/records`: Personal record badges and milestones.
- `GET /api/v1/activities/{id}/gpx`: Exports standard GPX XML route file with MIME type `application/gpx+xml`.

### Digital Detox & Focus Engine (`/api/v1/focus`, `/api/v1/blocker`, `/api/v1/usage-stats`)
- `GET /api/v1/focus/sessions`: Focus session history.
- `POST /api/v1/focus/sessions`: Records deep work session, awards 1 XP per minute of focus.
- `GET /api/v1/blocker/rules`: List package name blocking rules.
- `POST /api/v1/blocker/rules`: Creates or updates app blocking rule.
- `DELETE /api/v1/blocker/rules/{id}`: Removes app blocker rule.
- `POST /api/v1/usage-stats/sync`: Batch ingests daily screen time from Android `UsageStatsManager`.
- `GET /api/v1/usage-stats/summary`: Daily screen time totals vs user goal.

### Gamification & Leaderboard (`/api/v1/gamification`)
- `GET /api/v1/gamification/profile`: Current XP, current Level ($1-50$), title, progress bar percentage, and unlocked badge count.
- `GET /api/v1/gamification/badges`: Complete 30-badge catalog with user unlocked timestamp status.
- `GET /api/v1/gamification/leaderboard`: Global leaderboard of practitioners ranked by total XP.

### Open-Source AI Mentor (`/api/v1/ai`)
- `POST /api/v1/ai/chat`: Interactive chat with Sankalp Discipline Coach:
  - Dynamically injects user telemetry (current streak, enrolled challenge, habits completed today).
  - Preserves multi-turn conversation context.
  - Tracks token usage in `ai_usage_logs`.
  - Driven by open-source LLMs (`Llama 3.x`, `Qwen 2.5`, `Mistral`) via `OllamaDriver`, `GroqOpenRouterDriver`, `HuggingFaceDriver`, or `MockLlmDriver`.
- `GET /api/v1/ai/conversations`: Chat sessions list.
- `GET /api/v1/ai/conversations/{id}/messages`: Message history for a session.

---

## 3. Test Coverage Summary
All **28 backend test cases** pass with **479 assertions**:
- `AuthApiTest`: 6 tests passing (31 assertions)
- `QuizRoadmapApiTest`: 2 tests passing (320 assertions)
- `ChallengeApiTest`: 2 tests passing (38 assertions)
- `HabitApiTest`: 3 tests passing (14 assertions)
- `ActivityApiTest`: 4 tests passing (23 assertions)
- `GamificationAiApiTest`: 3 tests passing (33 assertions)
- `StreakServiceTest`: 6 tests passing (18 assertions)
- `ExampleTest`: 2 tests passing (2 assertions)
