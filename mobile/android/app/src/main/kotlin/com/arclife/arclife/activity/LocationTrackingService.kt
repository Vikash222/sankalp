package com.arclife.arclife.activity

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import com.arclife.arclife.MainActivity
import java.util.Locale

/**
 * Android 14+ Compliant Location Foreground Service.
 * Runs strictly while an activity (Run, Walk, Cycle, Hike) is in progress.
 * Provides lock-screen notification with live metrics and Pause/Resume/Stop actions.
 */
class LocationTrackingService : Service(), LocationListener {

    companion object {
        const val NOTIFICATION_ID = 9001
        const val CHANNEL_ID = "arclife_activity_tracking_channel"
        const val CHANNEL_NAME = "Sankalp Active Workout"

        const val EXTRA_ACTIVITY_TYPE = "extra_activity_type"
        const val EXTRA_NOTIFICATION_TITLE = "extra_notification_title"
        const val ACTION_START = "ACTION_START_TRACKING"
        const val ACTION_PAUSE = "ACTION_PAUSE_TRACKING"
        const val ACTION_RESUME = "ACTION_RESUME_TRACKING"
        const val ACTION_STOP = "ACTION_STOP_TRACKING"
        const val ACTION_UPDATE_STATS = "ACTION_UPDATE_STATS"

        const val EXTRA_DISTANCE_M = "extra_distance_m"
        const val EXTRA_ELAPSED_SEC = "extra_elapsed_sec"
        const val EXTRA_PACE_STR = "extra_pace_str"

        var isRunning: Boolean = false
            private set
        var isPaused: Boolean = false
            private set

        fun startTracking(context: Context, activityType: String, title: String) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_ACTIVITY_TYPE, activityType)
                putExtra(EXTRA_NOTIFICATION_TITLE, title)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun pauseTracking(context: Context) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                action = ACTION_PAUSE
            }
            context.startService(intent)
        }

        fun resumeTracking(context: Context) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                action = ACTION_RESUME
            }
            context.startService(intent)
        }

        fun stopTracking(context: Context) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun updateStats(context: Context, distanceM: Double, elapsedSec: Long, paceStr: String) {
            val intent = Intent(context, LocationTrackingService::class.java).apply {
                action = ACTION_UPDATE_STATS
                putExtra(EXTRA_DISTANCE_M, distanceM)
                putExtra(EXTRA_ELAPSED_SEC, elapsedSec)
                putExtra(EXTRA_PACE_STR, paceStr)
            }
            context.startService(intent)
        }
    }

    private var locationManager: LocationManager? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var currentActivityType: String = "Run"
    private var currentTitle: String = "Workout in Progress"

    private var cachedDistanceM: Double = 0.0
    private var cachedElapsedSec: Long = 0L
    private var cachedPaceStr: String = "--:--"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as? LocationManager

        val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
        wakeLock = powerManager?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "Sankalp:LocationTrackingWakeLock"
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: return START_NOT_STICKY

        when (action) {
            ACTION_START -> {
                currentActivityType = intent.getStringExtra(EXTRA_ACTIVITY_TYPE) ?: "Run"
                currentTitle = intent.getStringExtra(EXTRA_NOTIFICATION_TITLE) ?: "Sankalp $currentActivityType"
                startServiceForeground()
                startLocationUpdates()
                isRunning = true
                isPaused = false
                ActivityTrackingPlugin.notifyStatusChanged("tracking")
            }
            ACTION_PAUSE -> {
                isPaused = true
                stopLocationUpdates()
                updateNotification()
                ActivityTrackingPlugin.notifyStatusChanged("paused")
            }
            ACTION_RESUME -> {
                isPaused = false
                startLocationUpdates()
                updateNotification()
                ActivityTrackingPlugin.notifyStatusChanged("tracking")
            }
            ACTION_STOP -> {
                isRunning = false
                isPaused = false
                stopLocationUpdates()
                stopForeground(true)
                stopSelf()
                ActivityTrackingPlugin.notifyStatusChanged("stopped")
            }
            ACTION_UPDATE_STATS -> {
                cachedDistanceM = intent.getDoubleExtra(EXTRA_DISTANCE_M, cachedDistanceM)
                cachedElapsedSec = intent.getLongExtra(EXTRA_ELAPSED_SEC, cachedElapsedSec)
                cachedPaceStr = intent.getStringExtra(EXTRA_PACE_STR) ?: cachedPaceStr
                updateNotification()
            }
        }

        return START_NOT_STICKY
    }

    private fun startServiceForeground() {
        wakeLock?.acquire(4 * 60 * 60 * 1000L) // Max 4 hour safety timeout
        val notification = buildNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun startLocationUpdates() {
        try {
            val minTimeMs = 1000L // 1 second adaptive interval
            val minDistanceM = 1.0f // 1 meter threshold

            // 1. Immediately fetch best last known location to eliminate cold start wait
            var bestLastLocation: Location? = null
            val providers = listOfNotNull(
                LocationManager.GPS_PROVIDER,
                LocationManager.NETWORK_PROVIDER,
                LocationManager.PASSIVE_PROVIDER
            )

            for (provider in providers) {
                if (locationManager?.isProviderEnabled(provider) == true) {
                    val last = locationManager?.getLastKnownLocation(provider)
                    if (last != null) {
                        if (bestLastLocation == null || last.time > bestLastLocation.time) {
                            bestLastLocation = last
                        }
                    }
                }
            }

            if (bestLastLocation != null) {
                ActivityTrackingPlugin.sendLocation(bestLastLocation)
            }

            // 2. Concurrently register GPS, Network, and Passive providers
            var registeredAny = false

            if (locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true) {
                locationManager?.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    minTimeMs,
                    minDistanceM,
                    this
                )
                registeredAny = true
            }

            if (locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true) {
                locationManager?.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    minTimeMs,
                    minDistanceM,
                    this
                )
                registeredAny = true
            }

            if (locationManager?.isProviderEnabled(LocationManager.PASSIVE_PROVIDER) == true) {
                locationManager?.requestLocationUpdates(
                    LocationManager.PASSIVE_PROVIDER,
                    minTimeMs,
                    minDistanceM,
                    this
                )
                registeredAny = true
            }

            ActivityTrackingPlugin.notifyGpsStatus(registeredAny)
        } catch (e: SecurityException) {
            ActivityTrackingPlugin.notifyError("PERMISSION_DENIED", e.localizedMessage ?: "Location permission missing")
        }
    }

    private fun stopLocationUpdates() {
        try {
            locationManager?.removeUpdates(this)
        } catch (e: SecurityException) {
            // Ignored on cleanup
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Formatted statistics string
        val km = cachedDistanceM / 1000.0
        val minutes = cachedElapsedSec / 60
        val seconds = cachedElapsedSec % 60
        val timeFormatted = String.format(Locale.US, "%02d:%02d", minutes, seconds)
        val statsText = String.format(
            Locale.US,
            "%.2f km  •  %s  •  Pace: %s/km",
            km,
            timeFormatted,
            cachedPaceStr
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(if (isPaused) "$currentTitle (Paused)" else currentTitle)
            .setContentText(statsText)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        if (isPaused) {
            // Action: Resume
            val resumeIntent = Intent(this, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_RESUME
            }
            val resumePendingIntent = PendingIntent.getBroadcast(
                this,
                101,
                resumeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.addAction(android.R.drawable.ic_media_play, "Resume", resumePendingIntent)
        } else {
            // Action: Pause
            val pauseIntent = Intent(this, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_PAUSE
            }
            val pausePendingIntent = PendingIntent.getBroadcast(
                this,
                102,
                pauseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.addAction(android.R.drawable.ic_media_pause, "Pause", pausePendingIntent)
        }

        // Action: Stop
        val stopIntent = Intent(this, NotificationActionReceiver::class.java).apply {
            action = NotificationActionReceiver.ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            103,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent)

        return builder.build()
    }

    private fun updateNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.notify(NOTIFICATION_ID, buildNotification())
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows active distance, pace, and timer during workouts"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    override fun onLocationChanged(location: Location) {
        if (!isPaused && isRunning) {
            ActivityTrackingPlugin.sendLocation(location)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

    override fun onProviderEnabled(provider: String) {
        ActivityTrackingPlugin.notifyGpsStatus(true)
    }

    override fun onProviderDisabled(provider: String) {
        if (provider == LocationManager.GPS_PROVIDER) {
            ActivityTrackingPlugin.notifyGpsStatus(false)
        }
    }

    override fun onDestroy() {
        stopLocationUpdates()
        if (wakeLock?.isHeld == true) {
            wakeLock?.release()
        }
        isRunning = false
        isPaused = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
