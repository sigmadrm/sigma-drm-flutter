import 'package:flutter/cupertino.dart';

enum FPOutputType {
  OVERT(0),
  FORENSIC(1);

  final int value;
  const FPOutputType(this.value);

  static FPOutputType fromValue(int value) {
    return FPOutputType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FPOutputType.OVERT,
    );
  }
}

enum FPDisplayType {
  GLOBAL(0),
  INDIVIDUAL(1),
  GROUP(2);

  final int value;
  const FPDisplayType(this.value);

  static FPDisplayType fromValue(int value) {
    return FPDisplayType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FPDisplayType.GLOBAL,
    );
  }
}

enum FPDisplayAtType {
  AT_AUTO(0),
  AT_POSITION(1);

  final int value;
  const FPDisplayAtType(this.value);

  static FPDisplayAtType fromValue(int value) {
    return FPDisplayAtType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FPDisplayAtType.AT_AUTO,
    );
  }
}

class FingerprintSettings {
  final FPDisplayAtType displayAt;
  final bool displayMAC;
  final int duration;
  final int interval;
  final String message;
  final double opacity;
  final FPOutputType outputType;
  final FPDisplayType displayType;
  final int refreshInterval;
  final int repeat;
  final FingerprintStyleSettings settings;

  FingerprintSettings({
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

  bool equals(FingerprintSettings? other) {
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

  static FingerprintSettings? fromJson(Map<String, dynamic>? json) {
    debugPrint("FingerprintSettings fromJson = $json");
    if (json == null) return null;

    return FingerprintSettings(
      displayAt: FPDisplayAtType.fromValue(json['displayAt'] ?? 0),
      displayMAC: json['displayMAC'] ?? false,
      duration: json['duration'] ?? 0,
      interval: json['interval'] ?? 0, // FIXME: unused
      repeat: json['repeat'] ?? 0, // FIXME: unused
      message: json['message'] ?? '',
      opacity: (json['opacity']?.toDouble() ?? 0.0) / 100.0, // [0, 1.0]
      outputType: FPOutputType.fromValue(json['outputType'] ?? 0),
      displayType: FPDisplayType.fromValue(json['displayType'] ?? 0),
      refreshInterval: json['refreshInterval'] ?? 30,
      settings: FingerprintStyleSettings.fromJson(
        json['settings'] ?? <String, dynamic>{},
      ),
    );
  }
}

class FingerprintStyleSettings {
  final String bgColor;
  final bool displayBackground;
  final int fontSize;
  final int px;
  final int py;
  final String textColor;

  FingerprintStyleSettings({
    required this.bgColor,
    required this.displayBackground,
    required this.fontSize,
    required this.px,
    required this.py,
    required this.textColor,
  });

  bool equals(FingerprintStyleSettings other) {
    return bgColor == other.bgColor &&
        displayBackground == other.displayBackground &&
        fontSize == other.fontSize &&
        px == other.px &&
        py == other.py &&
        textColor == other.textColor;
  }

  factory FingerprintStyleSettings.fromJson(Map<String, dynamic> json) {
    return FingerprintStyleSettings(
      bgColor: json['bgColor'] ?? '#FFFFFF',
      displayBackground: json['displayBackground'] ?? false,
      fontSize: json['fontSize'] ?? 14,
      px: json['px'] ?? 10,
      py: json['py'] ?? 10,
      textColor: json['textColor'] ?? '#000000',
    );
  }
}
