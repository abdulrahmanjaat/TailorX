## ProGuard rules for TailorZ release AAB
# Keep Flutter and plugin entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Google Play services safe classes (if used)
-dontwarn com.google.**
