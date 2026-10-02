package com.arclife.arclife.activity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * BroadcastReceiver listening to user taps on notification action buttons
 * (Pause, Resume, Stop) during an active workout session.
 */
class NotificationActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_PAUSE = "com.arclife.app.ACTION_PAUSE_TRACKING"
        const val ACTION_RESUME = "com.arclife.app.ACTION_RESUME_TRACKING"
        const val ACTION_STOP = "com.arclife.app.ACTION_STOP_TRACKING"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_PAUSE -> {
                LocationTrackingService.pauseTracking(context)
            }
            ACTION_RESUME -> {
                LocationTrackingService.resumeTracking(context)
            }
            ACTION_STOP -> {
                LocationTrackingService.stopTracking(context)
            }
        }
    }
}
