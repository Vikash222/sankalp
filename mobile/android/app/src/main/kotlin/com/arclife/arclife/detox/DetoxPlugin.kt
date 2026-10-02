package com.arclife.arclife.detox

import android.app.AppOpsManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native MethodChannel & EventChannel implementation connecting Flutter to
 * Android Digital Detox, UsageStatsManager, DND toggling, and app blocker service.
 */
class DetoxPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        const val METHOD_CHANNEL_NAME = "com.arclife.app/detox"
        const val EVENT_CHANNEL_NAME = "com.arclife.app/detox_events"

        private var eventSink: EventChannel.EventSink? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        fun notifyAppBlocked(packageName: String, appName: String) {
            val map = hashMapOf<String, Any>(
                "event" to "app_blocked",
                "package_name" to packageName,
                "app_name" to appName,
                "timestamp" to System.currentTimeMillis()
            )
            mainHandler.post {
                eventSink?.success(map)
            }
        }

        fun notifyFocusSessionEnded(completedMinutes: Int, isSuccessful: Boolean) {
            val map = hashMapOf<String, Any>(
                "event" to "session_ended",
                "completed_minutes" to completedMinutes,
                "is_successful" to isSuccessful,
                "timestamp" to System.currentTimeMillis()
            )
            mainHandler.post {
                eventSink?.success(map)
            }
        }
    }

    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME).apply {
            setMethodCallHandler(this@DetoxPlugin)
        }
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: run {
            result.error("NO_CONTEXT", "Android context is null", null)
            return
        }

        when (call.method) {
            "hasUsageStatsPermission" -> {
                result.success(checkUsageStatsPermission(ctx))
            }

            "requestUsageStatsPermission" -> {
                try {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    ctx.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SETTINGS_ERROR", e.localizedMessage, null)
                }
            }

            "hasDndPermission" -> {
                val notificationManager = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                val hasAccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    notificationManager?.isNotificationPolicyAccessGranted == true
                } else {
                    true
                }
                result.success(hasAccess)
            }

            "requestDndPermission" -> {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        ctx.startActivity(intent)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("DND_SETTINGS_ERROR", e.localizedMessage, null)
                }
            }

            "setDndMode" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                val notificationManager = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && notificationManager != null) {
                    if (notificationManager.isNotificationPolicyAccessGranted) {
                        val filter = if (enabled) {
                            NotificationManager.INTERRUPTION_FILTER_PRIORITY
                        } else {
                            NotificationManager.INTERRUPTION_FILTER_ALL
                        }
                        notificationManager.setInterruptionFilter(filter)
                        result.success(true)
                    } else {
                        result.error("PERMISSION_DENIED", "Notification policy access not granted", null)
                    }
                } else {
                    result.success(true)
                }
            }

            "startFocusSession" -> {
                val blockedPackages = call.argument<List<String>>("blocked_packages") ?: emptyList()
                val durationMinutes = call.argument<Int>("duration_minutes") ?: 25
                val enableDnd = call.argument<Boolean>("enable_dnd") ?: true

                val serviceIntent = Intent(ctx, FocusMonitorService::class.java).apply {
                    action = FocusMonitorService.ACTION_START
                    putStringArrayListExtra(FocusMonitorService.EXTRA_BLOCKED_PACKAGES, ArrayList(blockedPackages))
                    putExtra(FocusMonitorService.EXTRA_DURATION_MINUTES, durationMinutes)
                    putExtra(FocusMonitorService.EXTRA_ENABLE_DND, enableDnd)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(serviceIntent)
                } else {
                    ctx.startService(serviceIntent)
                }
                result.success(true)
            }

            "stopFocusSession" -> {
                val serviceIntent = Intent(ctx, FocusMonitorService::class.java).apply {
                    action = FocusMonitorService.ACTION_STOP
                }
                ctx.startService(serviceIntent)
                result.success(true)
            }

            "getInstalledUserApps" -> {
                val pm = ctx.packageManager
                val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                val appList = mutableListOf<Map<String, Any>>()

                for (app in packages) {
                    // Filter to non-system user installed applications or common social/media apps
                    val isSystem = (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                    val isUpdatedSystem = (app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0

                    if (!isSystem || isUpdatedSystem || isCommonDistractionApp(app.packageName)) {
                        val label = pm.getApplicationLabel(app).toString()
                        appList.add(
                            mapOf(
                                "package_name" to app.packageName,
                                "app_name" to label,
                                "is_system" to isSystem
                            )
                        )
                    }
                }
                result.success(appList)
            }

            else -> result.notImplemented()
        }
    }

    private fun checkUsageStatsPermission(ctx: Context): Boolean {
        val appOps = ctx.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                ctx.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                ctx.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isCommonDistractionApp(pkg: String): Boolean {
        return pkg.contains("instagram") ||
                pkg.contains("youtube") ||
                pkg.contains("tiktok") ||
                pkg.contains("snapchat") ||
                pkg.contains("reddit") ||
                pkg.contains("twitter") ||
                pkg.contains("facebook") ||
                pkg.contains("netflix")
    }
}
