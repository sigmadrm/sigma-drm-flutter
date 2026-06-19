import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/color.dart';

enum SmMessageOutputType {
  MESSAGE(0),
  FORCE_FP(1);

  final int value;
  const SmMessageOutputType(this.value);

  static SmMessageOutputType fromValue(int value) {
    return SmMessageOutputType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SmMessageOutputType.MESSAGE,
    );
  }
}

class SmMessageSettings {
  final String id;
  final Color bgColor;
  final String body;
  final int duration;
  final double fontSize;
  final SmMessageOutputType outputType;
  final Color textColor;

  SmMessageSettings({
    required this.id,
    required this.bgColor,
    required this.body,
    required this.duration,
    required this.fontSize,
    required this.outputType,
    required this.textColor,
  });

  bool equals(SmMessageSettings? other) {
    if (other == null) return false;

    return id == other.id &&
        bgColor == other.bgColor &&
        body == other.body &&
        duration == other.duration &&
        fontSize == other.fontSize &&
        outputType == other.outputType &&
        textColor == other.textColor;
  }

  static SmMessageSettings? fromJson(Map<String, dynamic>? json) {
    debugPrint("SmMessageSettings from json = $json");
    if (json == null) return null;

    // Determine devicePixelRatio to convert physical pixels from backend to logical pixels
    double dpr = 1.0;
    try {
      dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    } catch (_) {}

    return SmMessageSettings(
      id: json['id'] ?? '',
      bgColor: smParseColor(json['bgColor'] ?? '#FFFFFF', Colors.white),
      body: json['body'] ?? '',
      duration: json['duration'] ?? 0,
      fontSize: (json['fontSize'] ?? 14) / dpr,
      outputType: SmMessageOutputType.fromValue(json['outputType'] ?? 0),
      textColor: smParseColor(json['textColor'] ?? '#000000', Colors.black),
    );
  }
}
