# Sankalp (संकल्प)

> **100% Free, Privacy-First Habit-Transformation & Digital Detox Platform**  
> Built with Flutter 3 (Android) and Laravel 11 LTS Backend (SQLite/MySQL).

---

## 🌟 Overview

**Sankalp** is an Android-first mobile application designed to cultivate stoic discipline, build lasting daily routines, and overcome smartphone addiction through a powerful digital detox app blocker.

- **Frontend:** Flutter 3.x, Riverpod 3.x, GoRouter 18.x
- **Backend:** Laravel 11 LTS, PHP 8.3, Sanctum Auth, SQLite / MySQL
- **Architecture:** 100% Offline-First with local SQLite & SharedPreferences storage and automatic cloud synchronization.

---

## 🚀 Key Features

1. **Habit Tracking & Streaks:**
   - Morning, Afternoon, Evening, and Anytime habit categories.
   - Customizable habits with XP rewards, streak freezes, and daily check-ins.
   - Interactive Habit Heatmap calendar.

2. **Digital Detox & Focus Blocker:**
   - Real-time foreground app blocker for distracting applications (Instagram, YouTube, BGMI, etc.).
   - Full-screen focus shields during deep work sessions.
   - Live countdown timer with custom app selection.

3. **Daily Protocols & Routines:**
   - Step-by-step Morning Monk and Evening Wind-Down protocols.
   - Scheduled push notification alerts for timely execution.

4. **Structured Arcs & Regimens:**
   - 21-Day Habit Builder, Summer Arc (Vitality), and Winter Arc (Monk Mode).

5. **Gamification & Leagues:**
   - 50 discipline levels with progressive XP requirements.
   - 30+ achievement badges.
   - Friends League rankings and referral invites.

6. **AI Mentorship:**
   - On-device and cloud AI mentor providing stoic guidance and discipline recommendations.

---

## 📂 Project Structure

```text
Sankalp/
├── mobile/               # Flutter mobile application
│   ├── lib/              # Clean Architecture Dart codebase
│   ├── android/          # Native Android configuration (Kotlin, Gradle)
│   └── test/             # Comprehensive widget & unit test suite
├── backend/              # Laravel 11 REST API
│   ├── app/              # Models, Controllers, Services
│   ├── routes/api.php    # RESTful API endpoints
│   ├── database/         # Migrations and SQLite seeders
│   └── Dockerfile        # Production container for free cloud deployment
├── render.yaml           # 1-Click Render.com deployment blueprint
└── README.md
```

---

## ☁️ 100% Free Cloud Deployment (Render.com)

1. Connect this repository to [Render.com](https://render.com).
2. Create a **Web Service** selecting **Docker** runtime (or use the blueprint `render.yaml`).
3. Set environment variable `DB_CONNECTION=sqlite`.
4. Deploy to get your live HTTPS endpoint (`https://sankalp-api.onrender.com`).

---

## 📱 Mobile Build Instructions

```bash
# Debug run
cd mobile
flutter run

# Production Release Android App Bundle (Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL=https://sankalp-api.onrender.com/api/v1
```

---

## 📄 License

This project is licensed under the MIT License.
