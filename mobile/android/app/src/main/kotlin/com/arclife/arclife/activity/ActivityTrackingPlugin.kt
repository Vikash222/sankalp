package com.arclife.arclife.activity

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * MethodChannel and EventChannel plugin connecting Flutter to
 * native Android LocationTrackingService with full runtime permission handling.
 */
class ActivityTrackingPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {

    companion object {
        const val METHOD_CHANNEL_NAME = "com.arclife.app/activity_tracker"
        const val LOCATION_EVENT_CHANNEL_NAME = "com.arclife.app/location_stream"
        const val STATUS_EVENT_CHANNEL_NAME = "com.arclife.app/status_stream"

        const val PERMISSION_REQUEST_LOCATION = 5001
        const val PERMISSION_REQUEST_NOTIFICATION = 5002

        private var locationEventSink: EventChannel.EventSink? = null
        private var statusEventSink: EventChannel.EventSink? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        fun sendLocation(location: Location) {
            val map = hashMapOf<String, Any>(
                "latitude" to location.latitude,
                "longitude" to location.longitude,
                "altitude" to location.altitude,
                "accuracy" to location.accuracy.toDouble(),
                "speed" to location.speed.toDouble(),
                "bearing" to location.bearing.toDouble(),
                "timestamp" to location.time
            )
            mainHandler.post {
                locationEventSink?.success(map)
            }
        }

        fun notifyStatusChanged(status: String) {
            val map = hashMapOf<String, Any>(
                "type" to "status",
                "value" to status
            )
            mainHandler.post {
                statusEventSink?.success(map)
            }
        }

        fun notifyGpsStatus(enabled: Boolean) {
            val map = hashMapOf<String, Any>(
                "type" to "gps_provider",
                "enabled" to enabled
            )
            mainHandler.post {
                statusEventSink?.success(map)
            }
        }

        fun notifyError(code: String, message: String) {
            val map = hashMapOf<String, Any>(
                "type" to "error",
                "code" to code,
                "message" to message
            )
            mainHandler.post {
                statusEventSink?.error(code, message, null)
            }
        }
    }

    private lateinit var applicationContext: Context
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private lateinit var methodChannel: MethodChannel
    private lateinit var locationEventChannel: EventChannel
    private lateinit var statusEventChannel: EventChannel

    private var pendingLocationPermissionResult: MethodChannel.Result? = null
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        locationEventChannel = EventChannel(binding.binaryMessenger, LOCATION_EVENT_CHANNEL_NAME)
        locationEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                locationEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                locationEventSink = null
            }
        })

        statusEventChannel = EventChannel(binding.binaryMessenger, STATUS_EVENT_CHANNEL_NAME)
        statusEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                statusEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                statusEventSink = null
            }
        })
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activity = null
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activity = null
        activityBinding = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasLocationPermission" -> {
                val fine = ContextCompat.checkSelfPermission(
                    applicationContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
                result.success(fine)
            }

            "requestLocationPermission" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "Cannot request permissions without foreground Activity", null)
                    return
                }

                val hasFine = ContextCompat.checkSelfPermission(
                    applicationContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED

                if (hasFine) {
                    result.success(true)
                    return
                }

                pendingLocationPermissionResult = result
                ActivityCompat.requestPermissions(
                    currentActivity,
                    arrayOf(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION
                    ),
                    PERMISSION_REQUEST_LOCATION
                )
            }

            "hasNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val granted = ContextCompat.checkSelfPermission(
                        applicationContext,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(granted)
                } else {
                    result.success(true)
                }
            }

            "requestNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val currentActivity = activity
                    if (currentActivity == null) {
                        result.error("NO_ACTIVITY", "Cannot request notification permission without Activity", null)
                        return
                    }

                    val granted = ContextCompat.checkSelfPermission(
                        applicationContext,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) == PackageManager.PERMISSION_GRANTED

                    if (granted) {
                        result.success(true)
                        return
                    }

                    pendingNotificationPermissionResult = result
                    ActivityCompat.requestPermissions(
                        currentActivity,
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        PERMISSION_REQUEST_NOTIFICATION
                    )
                } else {
                    result.success(true)
                }
            }

            "openAppSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", applicationContext.packageName, null)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    applicationContext.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("INTENT_ERROR", e.localizedMessage, null)
                }
            }

            "openLocationSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    applicationContext.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("INTENT_ERROR", e.localizedMessage, null)
                }
            }

            "startTracking" -> {
                val activityType = call.argument<String>("activityType") ?: "Run"
                val title = call.argument<String>("title") ?: "Sankalp Workout"
                LocationTrackingService.startTracking(applicationContext, activityType, title)
                result.success(true)
            }

            "pauseTracking" -> {
                LocationTrackingService.pauseTracking(applicationContext)
                result.success(true)
            }

            "resumeTracking" -> {
                LocationTrackingService.resumeTracking(applicationContext)
                result.success(true)
            }

            "stopTracking" -> {
                LocationTrackingService.stopTracking(applicationContext)
                result.success(true)
            }

            "updateNotificationStats" -> {
                val distanceM = call.argument<Double>("distanceM") ?: 0.0
                val elapsedSec = call.argument<Number>("elapsedSec")?.toLong() ?: 0L
                val paceStr = call.argument<String>("paceStr") ?: "--:--"
                LocationTrackingService.updateStats(applicationContext, distanceM, elapsedSec, paceStr)
                result.success(true)
            }

            "isGpsEnabled" -> {
                val lm = applicationContext.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
                val isGpsEnabled = (lm?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true) ||
                        (lm?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true)
                result.success(isGpsEnabled)
            }

            "isTrackingRunning" -> {
                result.success(LocationTrackingService.isRunning)
            }

            "isTrackingPaused" -> {
                result.success(LocationTrackingService.isPaused)
            }

            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            PERMISSION_REQUEST_LOCATION -> {
                val isGranted = grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED
                pendingLocationPermissionResult?.success(isGranted)
                pendingLocationPermissionResult = null
                return true
            }

            PERMISSION_REQUEST_NOTIFICATION -> {
                val isGranted = grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED
                pendingNotificationPermissionResult?.success(isGranted)
                pendingNotificationPermissionResult = null
                return true
            }
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        locationEventChannel.setStreamHandler(null)
        statusEventChannel.setStreamHandler(null)
        locationEventSink = null
        statusEventSink = null
    }
}
