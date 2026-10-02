package com.arclife.arclife.detox

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.arclife.arclife.MainActivity

/**
 * Foreground Service that enforces Deep Work focus sessions by monitoring
 * foreground applications via UsageStatsManager and redirecting away from
 * blacklisted distracting applications.
 */
class FocusMonitorService : Service() {

    companion object {
        const val ACTION_START = "com.arclife.app.detox.START"
        const val ACTION_STOP = "com.arclife.app.detox.STOP"

        const val EXTRA_BLOCKED_PACKAGES = "blocked_packages"
        const val EXTRA_DURATION_MINUTES = "duration_minutes"
        const val EXTRA_ENABLE_DND = "enable_dnd"

        private const val CHANNEL_ID = "sankalp_detox_channel"
        private const val NOTIFICATION_ID = 2001
        private const val BLOCKED_ALERT_NOTIFICATION_ID = 2002
    }

    private var blockedPackages: Set<String> = emptySet()
    private var durationSeconds: Int = 25 * 60
    private var secondsRemaining: Int = 25 * 60
    private var enableDnd: Boolean = true
    private var blockedAttemptsCount: Int = 0

    private val handler = Handler(Looper.getMainLooper())
    private var isMonitoring = false
    private var lastCheckedTimestamp: Long = 0

    private val monitorRunnable = object : Runnable {
        override fun run() {
            if (!isMonitoring) return

            if (secondsRemaining > 0) {
                secondsRemaining--
                checkForegroundApplication()
                updateNotification()
                handler.postDelayed(this, 1000)
            } else {
                finishSession(isSuccessful = true)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val pkgs = intent.getStringArrayListExtra(EXTRA_BLOCKED_PACKAGES) ?: arrayListOf()
                blockedPackages = pkgs.toSet()
                val minutes = intent.getIntExtra(EXTRA_DURATION_MINUTES, 25)
                durationSeconds = minutes * 60
                secondsRemaining = durationSeconds
                enableDnd = intent.getBooleanExtra(EXTRA_ENABLE_DND, true)
                blockedAttemptsCount = 0
                lastCheckedTimestamp = System.currentTimeMillis() - 5000

                if (enableDnd) {
                    toggleDnd(true)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        NOTIFICATION_ID,
                        buildNotification(),
                        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                    )
                } else {
                    startForeground(NOTIFICATION_ID, buildNotification())
                }
                isMonitoring = true
                handler.removeCallbacks(monitorRunnable)
                handler.post(monitorRunnable)
            }

            ACTION_STOP -> {
                finishSession(isSuccessful = false)
            }
        }
        return START_NOT_STICKY
    }

    private fun checkForegroundApplication() {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return
        val now = System.currentTimeMillis()
        var currentForegroundPackage: String? = null

        // Strategy 1: Check real-time UsageEvents stream
        val events = usageStatsManager.queryEvents(lastCheckedTimestamp, now)
        lastCheckedTimestamp = now

        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                currentForegroundPackage = event.packageName
            }
        }

        // Strategy 2: Fallback query for device models that throttle UsageEvents
        if (currentForegroundPackage == null || currentForegroundPackage == packageName) {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                now - 8000,
                now
            )
            val topApp = stats.filter { it.packageName != packageName }
                .maxByOrNull { it.lastTimeUsed }
            if (topApp != null && (now - topApp.lastTimeUsed) < 3000) {
                currentForegroundPackage = topApp.packageName
            }
        }

        if (currentForegroundPackage != null && currentForegroundPackage != packageName && blockedPackages.contains(currentForegroundPackage)) {
            handleBlockedAppTrigger(currentForegroundPackage)
        }
    }

    private fun handleBlockedAppTrigger(packageName: String) {
        blockedAttemptsCount++

        val appName = try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (_: Exception) {
            packageName
        }

        // 1. Kick user back to Sankalp or Home Screen
        val launchAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        try {
            startActivity(launchAppIntent)
        } catch (_: Exception) {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            try {
                startActivity(homeIntent)
            } catch (_: Exception) {}
        }

        // 2. Dispatch high-priority alert notification
        showBlockedNotification(appName)

        // 3. Notify Flutter layer
        DetoxPlugin.notifyAppBlocked(packageName, appName)
    }

    private fun showBlockedNotification(appName: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        val launchAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🛡️ Distraction Blocked by Sankalp")
            .setContentText("$appName is restricted during your active Deep Work session.")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setFullScreenIntent(pendingIntent, true)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(BLOCKED_ALERT_NOTIFICATION_ID, notification)
    }

    private fun toggleDnd(enable: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            if (notificationManager?.isNotificationPolicyAccessGranted == true) {
                val filter = if (enable) {
                    NotificationManager.INTERRUPTION_FILTER_PRIORITY
                } else {
                    NotificationManager.INTERRUPTION_FILTER_ALL
                }
                notificationManager.setInterruptionFilter(filter)
            }
        }
    }

    private fun finishSession(isSuccessful: Boolean) {
        isMonitoring = false
        handler.removeCallbacks(monitorRunnable)

        if (enableDnd) {
            toggleDnd(false)
        }

        val completedMinutes = (durationSeconds - secondsRemaining) / 60
        DetoxPlugin.notifyFocusSessionEnded(completedMinutes, isSuccessful)

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(): Notification {
        val minutes = secondsRemaining / 60
        val seconds = secondsRemaining % 60
        val timeFormatted = String.format("%02d:%02d", minutes, seconds)

        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            1,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, FocusMonitorService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            2,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sankalp Deep Work • Active")
            .setContentText("Focus time remaining: $timeFormatted • Blocked: $blockedAttemptsCount")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "End Early", stopPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun updateNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.notify(NOTIFICATION_ID, buildNotification())
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Sankalp Focus & Detox",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Live status notifications during Sankalp Deep Work focus sessions"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        isMonitoring = false
        handler.removeCallbacks(monitorRunnable)
        if (enableDnd) {
            toggleDnd(false)
        }
        super.onDestroy()
    }
}
