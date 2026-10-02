# Google Play Store Compliance, Policy Declarations & Release Packaging

This document provides the complete, authoritative compliance and submission blueprint for releasing **Sankalp** to the Google Play Store in full accordance with Google Play Developer Program Policies.

---

## 1. Sensitive Android Permissions & "Play Policy Risk" Analysis

Google Play strictly regulates background access, location data, notification policies, and app-usage inspection. Below is the risk classification and compliance strategy implemented in Sankalp.

### A. Location Permissions
* **Permissions Declared**:
  - `android.permission.ACCESS_FINE_LOCATION`
  - `android.permission.ACCESS_COARSE_LOCATION`
  - `android.permission.FOREGROUND_SERVICE_LOCATION`
* **Play Policy Category**: *Location in the Foreground / Foreground Services (Location)*
* **Policy Risk Assessment**:
  - Requesting background location (`ACCESS_BACKGROUND_LOCATION`) triggers mandatory declaration reviews, high rejection rates, and potential delisting unless strictly required as a core app function.
* **Safe Architecture Implemented**:
  - **No Background Location**: Sankalp **never** requests `ACCESS_BACKGROUND_LOCATION`.
  - **Foreground Service Only**: Location updates are only captured while an active GPS workout (Run, Walk, Cycle) is explicitly initiated by the user.
  - **Persistent Notification**: A prominent notification with live elapsed time, distance, and Pause/Resume/Stop controls remains visible throughout the workout session.
  - As soon as the workout terminates or is saved, the foreground service immediately shuts down (`stopForeground(STOP_FOREGROUND_REMOVE)` and `stopSelf()`), releasing all GPS hardware.

#### In-App Prominent Disclosure (Location)
Before triggering the Android system runtime permission dialog, Sankalp displays an in-app explanatory modal:

> **English**:
> *"Sankalp collects precise location data during active running, walking, and cycling workouts to draw your route on OpenStreetMap, calculate real-time pace, and record kilometer splits. Location data is only accessed while tracking is active and a persistent notification is visible. Sankalp never tracks your location in the background or sells your data."*



---

### B. Digital Detox & App Blocker Permissions
* **Permission Declared**:
  - `android.permission.PACKAGE_USAGE_STATS` (Special App Access: "Usage Access")
* **Play Policy Category**: *Accessibility & Device Usage Inspection Policy*
* **Policy Risk Assessment**:
  - Using `BIND_ACCESSIBILITY_SERVICE` for digital wellbeing or app blocking is heavily scrutinized and routinely rejected by Google Play Review unless the app is genuinely an assistive tool for people with disabilities.
* **Safe Architecture Implemented**:
  - Sankalp strictly uses `android.app.usage.UsageStatsManager` with `queryEvents()` to detect when a distracting app (e.g. doomscrolling) enters the foreground during an active user-initiated Pomodoro/Focus session.
  - When a blacklisted app is detected during active focus mode, the app blocker issues an Intent directing the system back to the Android Home screen (`Intent.CATEGORY_HOME`), accompanied by a gentle heads-up motivation banner.
  - Users are guided to Android's native Settings screen via `Settings.ACTION_USAGE_ACCESS_SETTINGS`.

#### In-App Prominent Disclosure (Usage Stats)
> **English**:
> *"To help you overcome digital distractions and stay committed to your focus sessions, Sankalp requests Usage Access. This allows Sankalp to identify when blocked apps are opened during active focus periods and redirect you to safety. No browsing history, keystrokes, personal messages, or private data are ever viewed, logged, or transmitted."*



---

### C. Do Not Disturb (DND) Policy
* **Permission Declared**:
  - `android.permission.ACCESS_NOTIFICATION_POLICY`
* **Play Policy Category**: *Notification Policy & Interruption Filters*
* **Safe Architecture Implemented**:
  - Used exclusively during active Pomodoro/Focus timers to engage `NotificationManager.INTERRUPTION_FILTER_PRIORITY`, silencing non-essential pings so the user can study or work uninterrupted.
  - Upon session completion or manual cancellation, the user's prior notification filter is immediately restored.

---

### D. Notifications (`POST_NOTIFICATIONS`)
* **Permission Declared**:
  - `android.permission.POST_NOTIFICATIONS` (Android 13+ / API 33+)
* **Purpose**:
  - Required for Android to display the foreground service status bar notification while recording GPS workouts and active focus sessions.
  - Delivering scheduled daily habit reminders configured by the user.

---

## 2. Google Play Console Data Safety Questionnaire Answers

When completing the **Data safety** section in the Google Play Console, submit the following verified declarations:

| Data Type | Collected? | Shared with 3rd Parties? | Ephemeral? | Purpose | User Deletable? |
| :--- | :---: | :---: | :---: | :--- | :---: |
| **Approximate Location** | Yes | No | No (User saved) | App functionality (Fitness tracking) | Yes |
| **Precise Location** | Yes | No | No (User saved) | App functionality (GPS route recording) | Yes |
| **App Activity (Usage data)** | Yes (Locally) | No | Yes (Processed on-device) | App functionality (Digital detox blocker) | N/A (Never sent off-device) |
| **User Account Info (Email/Name)** | Yes (Optional) | No | No | Account management & challenge sync | Yes (Account deletion in Settings) |
| **Fitness / Health Data (Workouts)** | Yes | No | No | App functionality (Mileage, Pace, Calories) | Yes |
| **Personal Identifiers (Device ID)** | Yes | No | No | FCM push notification routing | Yes |

* **Is data encrypted in transit?** `Yes` (All API traffic runs over HTTPS / TLS 1.3).
* **Can users request data deletion?** `Yes` (Users can delete individual workouts or their entire account directly from `ProfileScreen`).
* **Is the app targeted at children?** `No` (App target age is 13+).

---

## 3. Production Release Packaging (Android App Bundle - AAB)

Google Play requires applications to be distributed as an **Android App Bundle (.aab)** with 64-bit support and code shrinking (ProGuard / R8).

### Step 1: Generate Release Keystore
If you have not already created a production upload keystore, run:

```bash
keytool -genkey -v -keystore ./mobile/android/upload-keystore.jks \
        -keyalg RSA -keysize 4096 -validity 10000 \
        -alias sankalp_upload
```

### Step 2: Configure `mobile/android/key.properties`
Create `mobile/android/key.properties` (never commit this file to Git):

```properties
keyAlias=sankalp_upload
keyPassword=YourSecureKeyPasswordHere
storeFile=/absolute/path/to/Sankalp/mobile/android/upload-keystore.jks
storePassword=YourSecureStorePasswordHere
```

### Step 3: Compile Optimized & Obfuscated Android App Bundle
Run the following build command from the `mobile/` directory:

```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

#### What This Build Command Accomplishes:
1. **R8 Minification & Code Shrinking**: Strips dead code and unused classes across all libraries based on `mobile/android/app/proguard-rules.pro`.
2. **Resource Shrinking**: Removes unused drawables and layout resources.
3. **Dart Code Obfuscation**: Hides method names, class identifiers, and business logic from reverse engineering.
4. **Debug Symbols Output**: Emits crash symbolication files to `build/app/outputs/symbols`. These can be uploaded directly to the Google Play Console under **App Bundle Explorer > Downloads > Debug symbols** for automatic symbolication of crash reports.

The compiled App Bundle is generated at:
```
mobile/build/app/outputs/bundle/release/app-release.aab
```

---

## 4. Play Console Submission Checklist

- [ ] **Internal Testing**: Upload `app-release.aab` to the Internal Testing track.
- [ ] **Test Accounts**: Provide guest login credentials or test user details for Google Play reviewers.
- [ ] **App Content Disclosures**:
  - [ ] Complete **Data Safety** questionnaire (use Section 2 above).
  - [ ] Complete **Target Audience & Content** (Age 13+).
  - [ ] Complete **Government Apps** declaration (Not a government app).
  - [ ] Complete **Financial Features** declaration (None).
- [ ] **Permissions Declaration**:
  - [ ] For `FOREGROUND_SERVICE_LOCATION`: Select "Fitness and activity tracking". Provide a link to a short 15-second screen recording showing a user tapping "Start Workout", viewing the notification, and stopping the run.
- [ ] **Store Listing**:
  - Title: `Sankalp: Habit & Life Transformation`
  - Short Description: `Transform your lifestyle with 21-day challenges, GPS workouts, and detox.`
  - High-res icon: `512 x 512 PNG`
  - Feature Graphic: `1024 x 500 PNG`
  - Phone screenshots (minimum 4): Day Mode & Night Mode screens showcasing Challenge Dashboard, Live GPS Run, Digital Detox, and Gamification Badges.
