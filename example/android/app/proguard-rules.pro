# Flutter & Plugins
-keep class io.flutter.** { *; }

# Sigma DRM (Critical)
-keep class com.sigma.** { *; }

# System Security & Crypto
-keep class java.security.** { *; }
-keep interface java.security.** { *; }
-keep class javax.crypto.** { *; }
-keep interface javax.crypto.** { *; }
-keep class javax.security.** { *; }
-keep class android.security.keystore.** { *; }
-keep class java.util.UUID { *; }

# Network & Hardware
-keep class java.net.NetworkInterface { *; }
-keep class java.util.Enumeration { *; }
-keep class android.media.MediaDrm { *; }
-keep class android.media.MediaRouter { *; }

# Storage
-keep class android.content.SharedPreferences { *; }
-keep interface android.content.SharedPreferences$** { *; }

# SpongyCastle
-dontwarn org.spongycastle.**
-keep class org.spongycastle.** { *; }
-dontwarn javax.naming.**

# XML Parsers (kxml2)
-dontwarn org.xmlpull.v1.**
-dontwarn org.kxml2.**
-dontwarn android.content.res.XmlResourceParser
-keep class org.xmlpull.v1.** { *; }
-keep class org.kxml2.** { *; }

# ExoPlayer & Play Core
-dontwarn com.google.android.exoplayer2.**
-dontwarn com.google.android.play.core.**
