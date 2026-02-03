import 'package:flutter/foundation.dart';
import 'package:sigma_fingerprint_message/sigma_fingerprint_message.dart';
import 'package:video_player/video_player.dart' as video_player;
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

export 'package:video_player/video_player.dart';
export 'package:sigma_fingerprint_message/sigma_fingerprint_message.dart';
export 'package:video_player_control_panel/video_player_control_panel.dart';
export 'package:chewie/chewie.dart';

class SigmaVideoPlayer {
  /// Automatically sync Device ID from Sigma SDK to Fingerprint module
  ///
  /// This method initializes the video player platform and retrieves the device ID
  /// from the native Sigma SDK. The device ID is then set in the fingerprint module.
  ///
  /// IMPORTANT: This must be called after the Flutter engine is ready and before
  /// creating any video players, as it relies on the native SigmaHelper being initialized.
  static Future<void> init() async {
    try {
      // First, ensure the video player platform is initialized
      // This will call SigmaHelper.instance().init() on Android
      await VideoPlayerPlatform.instance.init();

      // Now we can safely get the device ID since SigmaHelper is initialized
      final String deviceId = await getSigmaDeviceId();
      debugPrint('[SigmaVideoPlayer] Auto-synced deviceId: $deviceId');
      SigmaFPM.instance.setDeviceId(deviceId);
    } catch (e) {
      debugPrint('[SigmaVideoPlayer] Failed to auto-sync deviceId: $e');
    }
  }

  /// Gets the Sigma device ID from the native SDK.
  ///
  /// This method retrieves the device ID from the video_player package,
  /// which in turn calls the native implementation.
  ///
  /// IMPORTANT: This must be called after [init] to ensure the native SDK is ready.
  static Future<String> getSigmaDeviceId() async {
    try {
      return await video_player.getSigmaDeviceId();
    } catch (e) {
      debugPrint('[SigmaVideoPlayer] Failed to get deviceId: $e');
      return "";
    }
  }
}
