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

# Gallery and sharing functionality
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class io.flutter.plugins.share.** { *; }
-keep class com.linusu.flutter_web_auth_2.** { *; }

# Gal (Gallery) plugin
-keep class studio.midoridesign.gal.** { *; }
-keep class io.flutter.plugins.gal.** { *; }

# Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# File picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# SQLite
-keep class com.tekartik.sqflite.** { *; }

# Signature plugin
-keep class io.flutter.plugins.signature.** { *; }

# Drawing board
-keep class com.flutter_drawing_board.** { *; }

# Don't obfuscate notification-related classes
-dontwarn com.dexterous.**
-dontwarn androidx.core.app.**

# Don't warn about missing classes from plugins
-dontwarn dev.fluttercommunity.plus.share.**
-dontwarn studio.midoridesign.gal.**
-dontwarn com.baseflow.permissionhandler.**
-dontwarn io.flutter.plugins.**

# Keep all model classes (they might be used via reflection)
-keep class com.example.digital_planner.models.** { *; }

# Keep all service classes
-keep class com.example.digital_planner.services.** { *; }

# Keep all database classes
-keep class com.example.digital_planner.database.** { *; }

# Keep all widget classes
-keep class com.example.digital_planner.widgets.** { *; }

# Keep all screen classes
-keep class com.example.digital_planner.screens.** { *; }