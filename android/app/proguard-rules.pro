# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Camera
-keep class androidx.camera.** { *; }

# For image_picker
-keep class androidx.exifinterface.** { *; }

# For path_provider
-keep class androidx.documentfile.** { *; }

# JSON serialization
-keep class * implements com.google.gson.TypeAdapter { *; }

# Platform channels
-keep class * extends java.lang.annotation.Annotation { *; }

# General rules
-dontwarn
-ignorewarnings