#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# XML Pull Parser - Fix kxml2 compatibility issues
-dontwarn org.xmlpull.v1.**
-dontwarn org.kxml2.**
-keep class org.xmlpull.v1.** { *; }
-keep interface org.xmlpull.v1.** { *; }
-keep class org.kxml2.** { *; }

# Ignore warnings about Android SDK classes implementing library interfaces
-dontwarn android.content.res.XmlResourceParser


# SpongyCastle and javax.naming
-dontwarn javax.naming.**
-dontwarn org.spongycastle.**
-keep class org.spongycastle.** { *;}

# Play Core (Deferred Components)
-dontwarn com.google.android.play.core.**

# Sigma DRM
-keep class com.sigma.** { *; }
-keepclasseswithmembers class com.sigma.** { *; }
-keepclassmembers class com.sigma.** {
    <fields>;
    <methods>;
}
-keep interface com.sigma.** { *; }
