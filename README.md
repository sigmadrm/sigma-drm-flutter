# sigma-drm-flutter

`sigma-drm-flutter` is a **high-performance Flutter plugin** for integrating **SigmaDRM** into Flutter applications.  
It enables secure DRM video playback with **automated Fingerprint and Message overlays**, optimized for **Android Mobile** and **Android TV** platforms.

The plugin is built on top of Flutter’s `video_player` and is designed for **OTT / IPTV / Streaming** applications.

---

## ✨ Features

- 🔐 **SigmaDRM Integration**  
  Secure DRM protection for video content using SigmaDRM.

- 🖼 **Fingerprint & Message Overlay (FPM)**

- 🎛 **Customizable Video Controls**  
  Integrated with `video_player_control_panel` for flexible UI customization, or use `chewie` for Material and Cupertino-styled video controls.

- 🚀 **High Performance**  
  Optimized for large-scale streaming apps and Android TV devices.

---

## 📦 Installation

Add `sigma_video_player` to your `pubspec.yaml`:

```yaml
dependencies:
  sigma_video_player:
    git:
      url: https://github.com/sigmadrm/sigma-drm-flutter.git
      ref: v1.2.0 # Replace with the latest version
```

Install dependencies:

```bash
flutter pub get
```

---

## 📱 Platform Support

| Platform       | Status                          |
| -------------- | ------------------------------- |
| Android Mobile | ✅ Supported                    |
| Android Tablet | ✅ Supported                    |
| Android TV     | ✅ Supported (TV Box, Smart TV) |

---

## 🛠 Android Build Configuration

To prevent **Release build crashes** caused by Obfuscation (R8/ProGuard), you **must** add the following rules to `android/app/proguard-rules.pro`.

📌 **Reference ProGuard Rules:**  
[example/android/app/proguard-rules.pro](example/android/app/proguard-rules.pro)

---

## 🚀 Usage Guide

### 1️⃣ Initialize SigmaVideoPlayer

The plugin **must be initialized before running the application**.

```dart
import 'package:flutter/widgets.dart';
import 'package:sigma_video_player/sigma_video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SigmaVideoPlayer.init();

  runApp(const MyApp());
}
```

---

### 2️⃣ Configure Fingerprint & Message (FPM)

Configure the global Fingerprint & Message module.

```dart
SigmaFPM.instance.setConfig(
  apiBaseUrl: "SIGMA_DRM_CMS_API_BASE_URL",
  accessToken: 'YOUR_JWT_ACCESS_TOKEN',
);

// Start fetching configuration from SigmaDRM API
SigmaFPM.instance.start();
```

---

### 3️⃣ Wrap Application UI with Overlay

To ensure Fingerprint and Message overlays persist correctly (especially in **fullscreen mode**), you should wrap your `MaterialApp` using the `builder` property. This places the overlay above the Navigator.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // ... other properties
    builder: (context, child) {
      return SigmaFPM.instance.buildOverlay(
        child: child ?? const SizedBox(),
      );
    },
    home: const MyApp(),
  );
}
```

---

### 4️⃣ Custom Fingerprint UI (Optional)

By default, the SDK provides a built-in Fingerprint overlay that strictly follows the CMS settings (including positioning, text size, opacity, and color). However, you can provide a **Custom Fingerprint Builder** to fully control the layout (e.g., adding an icon, a border, or changing the position) while still utilizing the pre-computed CMS styles.

When building a custom Fingerprint widget, the SDK provides `SmFingerprintSettings` (containing all style properties) and the `fingerprintId` string.

**1. Define your custom builder:**
```dart
import 'package:flutter/material.dart';
import 'package:sigma_video_player/sigma_video_player.dart';

Widget customFingerprintBuilder(
  SmFingerprintSettings settings,
  String fingerprintId,
) {
  final style = settings.settings;
  return Positioned(
    // App controls the absolute positioning (ignores CMS offset x/y)
    bottom: 32,
    right: 16,
    child: Opacity(
      opacity: settings.opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: style.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: style.textColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (settings.message.isNotEmpty)
              Text(
                settings.message,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: style.fontSize,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  inherit: false,
                ),
              ),
            if (settings.showDeviceId)
              Text(
                fingerprintId,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: style.fontSize,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                  inherit: false,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

**2. Pass the custom builder to `buildOverlay`:**

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    builder: (context, child) {
      return SigmaFPM.instance.buildOverlay(
        fingerprintWidgetBuilder: customFingerprintBuilder, // Inject custom UI here
        child: child ?? const SizedBox(),
      );
    },
    home: const MyApp(),
  );
}
```

> **Note:** A stateless custom builder will bypass the SDK's automatic Overt/Forensic layout behaviors (like random periodic repositioning or forensic blinking). If your application requires those real-time behaviors within a custom layout, you must implement the state timer logic inside your custom widget wrapper.

---

### 5️⃣ DRM Video Playback

Create a `VideoPlayerController` with DRM configuration.

```dart
final controller = VideoPlayerController.networkUrl(
  Uri.parse('https://your-stream-url.mpd'),
  drmConfiguration: {
    'merchantId': 'YOUR_MERCHANT_ID',
    'appId': 'YOUR_APP_ID',
    'userId': 'YOUR_USER_ID',
    'sessionId': 'YOUR_SESSION_ID',
  },
);

await controller.initialize();
controller.play();
```

---

### 6️⃣ Update Channel ID When Switching Content

```dart
SigmaFPM.instance.setChannelId('YOUR_CHANNEL_ID');
```

---

### 7️⃣ Update Access Token Dynamically

If your application refreshes the authentication token during a session, you can update it without restarting the module.

```dart
SigmaFPM.instance.setAccessToken('YOUR_JWT_ACCESS_TOKEN');
```

---

### 8️⃣ Get Sigma Device ID

You can retrieve the unique device identifier used by SigmaDRM.

```dart
String deviceId = await SigmaVideoPlayer.getSigmaDeviceId();
```

---

## 🔧 Configuration Parameters

| Placeholder                  | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| `SIGMA_DRM_CMS_API_BASE_URL` | SigmaDRM CMS API base URL                                                            |
| `YOUR_JWT_ACCESS_TOKEN`      | JWT token used to authenticate the user with SigmaDRM CMS                            |
| `YOUR_MERCHANT_ID`           | Merchant ID provided by SigmaDRM                                                     |
| `YOUR_APP_ID`                | Application ID provided by SigmaDRM                                                  |
| `YOUR_USER_ID`               | Current user identifier                                                              |
| `YOUR_SESSION_ID`            | Session ID for SigmaDRM license authentication                                       |
| `YOUR_CHANNEL_ID`            | A unique identifier for the current channel or content, generated by the SMS system. |

---

## ▶️ Run the Example Application

```bash
cd example
flutter pub get
flutter run
```

---

## 📚 Reference

- [video_player](https://pub.dev/packages/video_player): Official Flutter plugin for cross-platform video playback, used as the base player in this project.
- [chewie](https://pub.dev/packages/chewie): A video player for Flutter with Material and Cupertino skins, providing customizable UI controls for video playback.
- [video_player_control_panel](https://pub.dev/packages/video_player_control_panel): A flexible and customizable control panel for Flutter video players, offering granular control over UI elements.
