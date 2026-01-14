import 'package:flutter/cupertino.dart';

enum MessageOutputType {
  MESSAGE(0),
  FORCE_FP(1);

  final int value;
  const MessageOutputType(this.value);

  static MessageOutputType fromValue(int value) {
    return MessageOutputType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageOutputType.MESSAGE,
    );
  }
}

class MessageSettings {
  final String id;
  final String bgColor;
  final String body;
  final int duration;
  final int fontSize;
  final MessageOutputType outputType;
  final String textColor;

  MessageSettings({
    required this.id,
    required this.bgColor,
    required this.body,
    required this.duration,
    required this.fontSize,
    required this.outputType,
    required this.textColor,
  });

  bool equals(MessageSettings? other) {
    if (other == null) return false;

    return id == other.id &&
        bgColor == other.bgColor &&
        body == other.body &&
        duration == other.duration &&
        fontSize == other.fontSize &&
        outputType == other.outputType &&
        textColor == other.textColor;
  }

  static MessageSettings? fromJson(Map<String, dynamic>? json) {
    debugPrint("MessageSettings from json = $json");
    if (json == null) return null;

    return MessageSettings(
      id: json['id'] ?? '',
      bgColor: json['bgColor'] ?? '#FFFFFF',
      body: json['body'] ?? '',
      duration: json['duration'] ?? 0,
      fontSize: json['fontSize'] ?? 14,
      outputType: MessageOutputType.fromValue(json['outputType'] ?? 0),
      textColor: json['textColor'] ?? '#000000',
    );
  }
}
