package com.arclife.arclife

import androidx.annotation.NonNull
import com.arclife.arclife.activity.ActivityTrackingPlugin
import com.arclife.arclife.detox.DetoxPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ActivityTrackingPlugin())
        flutterEngine.plugins.add(DetoxPlugin())
    }
}
