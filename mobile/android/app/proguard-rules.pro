# ==============================================================================
# Sankalp - ProGuard & R8 Code Shrinking & Obfuscation Rules
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Crash Symbolication & Line Number Retention
# ------------------------------------------------------------------------------
# Retain line number tables and source file attributes so Play Console can
# symbolicate and deobfuscate stack traces using mapping.txt / split-debug-info.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Retain annotations, generic type signatures, and enclosing methods
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Exceptions

# ------------------------------------------------------------------------------
# 2. Flutter Engine and Embedding
# ------------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ------------------------------------------------------------------------------
# 3. AndroidX Support & Core Libraries
# ------------------------------------------------------------------------------
-keep class androidx.lifecycle.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.content.ContextCompat { *; }
-keep class androidx.annotation.Keep

-keep @androidx.annotation.Keep class * { *; }
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}

# ------------------------------------------------------------------------------
# 4. Sankalp Native Kotlin Services & Plugins
# ------------------------------------------------------------------------------
# Retain native services and broadcast receivers registered in AndroidManifest.xml
-keep class com.arclife.arclife.MainActivity { *; }
-keep class com.arclife.arclife.activity.LocationTrackingService { *; }
-keep class com.arclife.arclife.activity.NotificationActionReceiver { *; }
-keep class com.arclife.arclife.activity.ActivityTrackingPlugin { *; }
-keep class com.arclife.arclife.detox.FocusMonitorService { *; }
-keep class com.arclife.arclife.detox.DetoxPlugin { *; }

# ------------------------------------------------------------------------------
# 5. Networking & HTTP (Dio / OkHttp3 / Okio)
# ------------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keepattributes *JavascriptInterface*

# ------------------------------------------------------------------------------
# 6. JSON Serialization & Safe Model Deserialization
# ------------------------------------------------------------------------------
# Keep classes with Serializable or Parcelable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ------------------------------------------------------------------------------
# 7. Suppress Unused Class Warnings from Vendor Packages
# ------------------------------------------------------------------------------
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn com.google.android.play.core.**

