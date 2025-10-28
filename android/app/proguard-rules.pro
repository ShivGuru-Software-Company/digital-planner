# Flutter Local Notifications - Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class * extends androidx.core.app.NotificationCompat$Style { *; }

# Keep notification receiver classes
-keep class * extends android.content.BroadcastReceiver { *; }

# Keep timezone data for scheduled notifications
-keep class org.threeten.bp.** { *; }
-keep class com.jakewharton.threetenabp.** { *; }

# Keep Flutter Local Notifications plugin classes
-keep class io.flutter.plugins.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Don't obfuscate notification-related classes
-dontwarn com.dexterous.**
-dontwarn androidx.core.app.**