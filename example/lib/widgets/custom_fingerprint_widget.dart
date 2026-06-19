import 'package:flutter/material.dart';
import 'package:sigma_video_player/sigma_video_player.dart';

// ============================================================================
// [SDK] Custom fingerprint widget builder
//
// This function matches the [SmFingerprintWidgetBuilder] typedef.
// It allows the host app to fully customize the layout (like adding an icon
// or border) while still respecting CMS-driven styling like colors and fonts.
//
// Note: Offset settings (px, py) from CMS are intentionally ignored here
// to demonstrate that the app can dictate its own position (bottom right).
// ============================================================================

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
