import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/color.dart';

enum SmFPOutputType {
  OVERT(0),
  FORENSIC(1);

  final int value;
  const SmFPOutputType(this.value);

  static SmFPOutputType fromValue(int value) {
    return SmFPOutputType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SmFPOutputType.OVERT,
    );
  }
}

enum SmFPDisplayType {
  GLOBAL(0),
  INDIVIDUAL(1),
  GROUP(2);

  final int value;
  const SmFPDisplayType(this.value);

  static SmFPDisplayType fromValue(int value) {
    return SmFPDisplayType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SmFPDisplayType.GLOBAL,
    );
  }
}

enum SmFPDisplayAtType {
  AT_AUTO(0),
  AT_POSITION(1);

  final int value;
  const SmFPDisplayAtType(this.value);

  static SmFPDisplayAtType fromValue(int value) {
    return SmFPDisplayAtType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SmFPDisplayAtType.AT_AUTO,
    );
  }
}

class SmFingerprintSettings {
  final SmFPDisplayAtType displayAt;
  final bool displayMAC;
  final int duration;
  final int interval;
  final String message;
  final double opacity;
  final SmFPOutputType outputType;
  final SmFPDisplayType displayType;
  final int refreshInterval;
  final int repeat;
  final SmFingerprintStyleSettings settings;

  SmFingerprintSettings({
    required this.displayAt,
    required this.displayMAC,
    required this.duration,
    required this.interval,
    required this.message,
    required this.opacity, // [0, 1.0]
    required this.outputType,
    required this.displayType,
    required this.refreshInterval,
    required this.repeat,
    required this.settings,
  });

  bool get showDeviceId =>
      outputType == SmFPOutputType.FORENSIC ||
      (outputType == SmFPOutputType.OVERT && displayMAC);

  bool equals(SmFingerprintSettings? other) {
    if (other == null) return false;
    return displayAt == other.displayAt &&
        displayMAC == other.displayMAC &&
        duration == other.duration &&
        interval == other.interval &&
        message == other.message &&
        opacity == other.opacity &&
        outputType == other.outputType &&
        displayType == other.displayType &&
        refreshInterval == other.refreshInterval &&
        repeat == other.repeat &&
        settings.equals(other.settings);
  }

  static SmFingerprintSettings? fromJson(Map<String, dynamic>? json) {
    debugPrint("SmFingerprintSettings fromJson = $json");
    if (json == null) return null;

    return SmFingerprintSettings(
      displayAt: SmFPDisplayAtType.fromValue(json['displayAt'] ?? 0),
      displayMAC: json['displayMAC'] ?? false,
      duration: json['duration'] ?? 0,
      interval: json['interval'] ?? 0, // FIXME: unused
      repeat: json['repeat'] ?? 0, // FIXME: unused
      message: json['message'] ?? '',
      opacity: (json['opacity']?.toDouble() ?? 0.0) / 100.0, // [0, 1.0]
      outputType: SmFPOutputType.fromValue(json['outputType'] ?? 0),
      displayType: SmFPDisplayType.fromValue(json['displayType'] ?? 0),
      refreshInterval: json['refreshInterval'] ?? 30,
      settings: SmFingerprintStyleSettings.fromJson(
        json['settings'] ?? <String, dynamic>{},
      ),
    );
  }
}

class SmFingerprintStyleSettings {
  final Color bgColor;
  final bool displayBackground;
  final double fontSize;
  final double px;
  final double py;
  final Color textColor;

  SmFingerprintStyleSettings({
    required this.bgColor,
    required this.displayBackground,
    required this.fontSize,
    required this.px,
    required this.py,
    required this.textColor,
  });

  bool equals(SmFingerprintStyleSettings other) {
    return bgColor == other.bgColor &&
        displayBackground == other.displayBackground &&
        fontSize == other.fontSize &&
        px == other.px &&
        py == other.py &&
        textColor == other.textColor;
  }

  factory SmFingerprintStyleSettings.fromJson(Map<String, dynamic> json) {
    // Determine devicePixelRatio to convert physical pixels from backend to logical pixels
    double dpr = 1.0;
    try {
      dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    } catch (_) {}

    final displayBg = json['displayBackground'] ?? false;

    return SmFingerprintStyleSettings(
      bgColor: displayBg
          ? smParseColor(
              json['bgColor'] ?? '#000000',
              Colors.black,
            ).withValues(alpha: 0.8)
          : Colors.transparent,
      displayBackground: displayBg,
      fontSize: (json['fontSize'] ?? 14) / dpr,
      px: (json['px'] ?? 10) / dpr,
      py: (json['py'] ?? 10) / dpr,
      textColor: smParseColor(json['textColor'] ?? '#FFFFFF', Colors.white),
    );
  }
}

/// Builder callback that allows the host app to render a custom fingerprint UI.
/// - [settings]: the current fingerprint configuration received from the server.
/// - [fingerprintId]: the device/session ID that accompanies the settings.
///
/// When provided to [SigmaFPM.buildOverlay], the SDK will NOT render the
/// default [FingerprintOverlay]. Instead this builder is called whenever
/// [SmFingerprintSettings] or [fingerprintId] changes, and the returned
/// [Widget] is displayed in its place.
typedef SmFingerprintWidgetBuilder =
    Widget Function(SmFingerprintSettings settings, String fingerprintId);
