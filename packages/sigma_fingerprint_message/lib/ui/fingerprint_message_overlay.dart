import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/fingerprint_settings.dart';
import '../models/message_settings.dart';
import 'fingerprint_overlay.dart';
import 'message_overlay.dart';

class SigmaFPMOverlay extends StatefulWidget {
  final Widget child;
  final ValueListenable<FingerprintSettings?> fingerprintListenable;
  final ValueListenable<MessageSettings?> messageListenable;
  final ValueListenable<String> deviceIdListenable;
  final VoidCallback? onMessageExpired;
  final VoidCallback? onFingerprintExpired;

  const SigmaFPMOverlay({
    super.key,
    required this.deviceIdListenable,
    required this.fingerprintListenable,
    required this.messageListenable,
    required this.child,
    this.onMessageExpired,
    this.onFingerprintExpired,
  });

  @override
  State<SigmaFPMOverlay> createState() => _SigmaFPMOverlayState();
}

class _SigmaFPMOverlayState extends State<SigmaFPMOverlay> {
  Timer? _messageTimer;
  Timer? _fingerprintTimer;

  @override
  void initState() {
    super.initState();
    widget.messageListenable.addListener(_handleMessageChange);
    widget.fingerprintListenable.addListener(_handleFingerprintChange);
  }

  @override
  void dispose() {
    widget.messageListenable.removeListener(_handleMessageChange);
    widget.fingerprintListenable.removeListener(_handleFingerprintChange);
    _cancelMessageTimer();
    _cancelFingerprintTimer();
    super.dispose();
  }

  void _handleMessageChange() {
    final settings = widget.messageListenable.value;

    _cancelMessageTimer();

    if (settings != null && settings.duration > 0) {
      _messageTimer = Timer(Duration(seconds: settings.duration), () {
        widget.onMessageExpired?.call();
      });
    }
  }

  void _handleFingerprintChange() {
    final settings = widget.fingerprintListenable.value;

    _cancelFingerprintTimer();

    if (settings != null && settings.duration > 0) {
      _fingerprintTimer = Timer(Duration(seconds: settings.duration), () {
        widget.onFingerprintExpired?.call();
      });
    }
  }

  void _cancelMessageTimer() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  void _cancelFingerprintTimer() {
    _fingerprintTimer?.cancel();
    _fingerprintTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 0 — App content (NEVER rebuild)
        widget.child,

        // Layer 1 — Message overlay (rebuild when message OR deviceId changes)
        ValueListenableBuilder<MessageSettings?>(
          valueListenable: widget.messageListenable,
          builder: (_, messageSettings, __) {
            if (messageSettings == null) return const SizedBox.shrink();

            return ValueListenableBuilder<String>(
              valueListenable: widget.deviceIdListenable,
              builder: (_, deviceId, __) {
                return MessageOverlay(
                  settings: messageSettings,
                  deviceId: deviceId,
                );
              },
            );
          },
        ),

        // Layer 2 — Fingerprint overlay (rebuild when fingerprint OR deviceId changes)
        ValueListenableBuilder<FingerprintSettings?>(
          valueListenable: widget.fingerprintListenable,
          builder: (_, fingerprintSettings, __) {
            if (fingerprintSettings == null) return const SizedBox.shrink();

            return ValueListenableBuilder<String>(
              valueListenable: widget.deviceIdListenable,
              builder: (_, deviceId, __) {
                return FingerprintOverlay(
                  settings: fingerprintSettings,
                  deviceId: deviceId,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
