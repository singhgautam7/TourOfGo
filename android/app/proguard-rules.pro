# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# url_launcher (Android plugin uses Intent reflection in some flavors)
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Don't choke on Play Core (referenced transitively but not used)
-dontwarn com.google.android.play.core.**
