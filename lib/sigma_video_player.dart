import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sigma_fingerprint_message/sigma_fingerprint_message.dart';

export 'package:video_player/video_player.dart';
export 'package:sigma_fingerprint_message/sigma_fingerprint_message.dart';
export 'package:video_player_control_panel/video_player_control_panel.dart';
export 'package:chewie/chewie.dart';

class SigmaVideoPlayer {
  static const MethodChannel _channel = MethodChannel('sigma_video_player');

  /// Automatically sync Device ID from Sigma SDK to Fingerprint module
  static Future<void> init() async {
    try {
      final String? deviceId = await getSigmaDeviceId();
      debugPrint('[SigmaVideoPlayer] Auto-synced deviceId: $deviceId');
      SigmaFPM.instance.setDeviceId(deviceId);
    } catch (e) {
      debugPrint('[SigmaVideoPlayer] Failed to auto-sync deviceId: $e');
    }
  }

  static Future<String> getSigmaDeviceId() async {
    try {
      final String deviceId =
          await _channel.invokeMethod('getSigmaDeviceId') ?? '';
      return deviceId;
    } catch (e) {
      debugPrint('[SigmaVideoPlayer] Failed to get deviceId: $e');
      return "";
    }
  }
}
