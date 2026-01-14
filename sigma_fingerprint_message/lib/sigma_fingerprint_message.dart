import 'dart:async';
import 'package:flutter/material.dart';
import 'models/fingerprint_settings.dart';
import 'models/message_settings.dart';
import 'api/api_client.dart';
import 'ui/fingerprint_message_overlay.dart';

class SigmaFPM {
  static final SigmaFPM instance = SigmaFPM._internal();

  SigmaFPM._internal();

  late final ApiClient _apiClient;

  /// Channel ID: use for request fingerprint
  String? _channelId;

  Map<String, dynamic> _config = {
    // 'apiBaseUrl': 'https://develop-api-drm-cms-e2e.sigmadrm.com',
    'apiBaseUrl': 'https://audit-drm-api-dev.sigmadrm.com',
    'accessToken': '',
    'refreshInterval': 30,
  };

  Timer? _refreshTimer;
  FingerprintSettings? _lastValidFingerprint;
  MessageSettings? _lastValidMessage;

  // ================================
  // 3️⃣ NOTIFIERS (UI binding)
  // ================================
  final ValueNotifier<String> deviceIdListenable = ValueNotifier('');
  final ValueNotifier<FingerprintSettings?> fingerprintListenable =
      ValueNotifier(null);
  final ValueNotifier<MessageSettings?> messageListenable = ValueNotifier(null);

  // ================================
  // 4️⃣ CONFIG
  // ================================

  void setConfig({
    String? apiBaseUrl,
    String? accessToken,
    int? refreshInterval,
  }) {
    debugPrint(
      '[SigmaFPM] setConfig: $apiBaseUrl, $accessToken, $refreshInterval',
    );
    _config = {
      ..._config,
      'apiBaseUrl': apiBaseUrl ?? _config['apiBaseUrl'],
      'accessToken': accessToken ?? _config['accessToken'],
      'refreshInterval': refreshInterval ?? _config['refreshInterval'],
    };

    _apiClient = ApiClient(apiBaseUrl: _config['apiBaseUrl']);
    _apiClient.setAccessToken(_config['accessToken']);
  }

  void setDeviceId(String? deviceId) {
    deviceIdListenable.value = deviceId ?? "";
  }

  void setChannelId(String channelId) {
    if (_channelId == channelId) return;
    _channelId = channelId;
    _fetchFingerprintMessage();
  }

  void setAccessToken(String accessToken) {
    _config['accessToken'] = accessToken;
    _apiClient.setAccessToken(accessToken);
    _fetchFingerprintMessage();
  }

  Map<String, dynamic> get config => Map.unmodifiable(_config);

  // ================================
  // 5️⃣ LIFECYCLE
  // ================================
  bool _started = false;

  void start() {
    if (_started) return;

    _started = true;
    _fetchFingerprintMessage();
  }

  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _started = false;

    _lastValidFingerprint = null;
    _lastValidMessage = null;
    fingerprintListenable.value = null;
    messageListenable.value = null;
  }

  void dispose() {
    stop();
    deviceIdListenable.dispose();
    fingerprintListenable.dispose();
    messageListenable.dispose();
  }

  // ================================
  // 6️⃣ UI OVERLAY
  // ================================
  Widget buildOverlay({required Widget child}) {
    debugPrint(
      "[SigmaFPM] buildOverlay with deviceId=${deviceIdListenable.value}, fingerprints=${fingerprintListenable.value}, message=${messageListenable.value}",
    );
    return SigmaFPMOverlay(
      deviceIdListenable: deviceIdListenable,
      fingerprintListenable: fingerprintListenable,
      messageListenable: messageListenable,
      onMessageExpired: () {
        messageListenable.value = null;
      },
      onFingerprintExpired: () {
        fingerprintListenable.value = null;
      },
      child: child,
    );
  }

  // ================================
  // 7️⃣ INTERNAL LOGIC
  // ================================
  void _scheduleNextFetch() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(
      Duration(seconds: _config['refreshInterval'] as int),
      _fetchFingerprintMessage,
    );
  }

  Future<void> _fetchFingerprintMessage() async {
    try {
      final fpmSettings = await _apiClient.fetchFPMSettings(
        channelId: _channelId,
      );
      _updateFingerprintSetting(fpmSettings.fingerprintSettings);
      _updateMessageSetting(fpmSettings.messageSettings);
    } catch (e) {
      debugPrint('[Sigma] Fetch error: $e');
    } finally {
      if (_started) {
        _scheduleNextFetch();
      }
    }
  }

  void _updateFingerprintSetting(FingerprintSettings? settings) {
    if (settings == null) {
      fingerprintListenable.value = null;
      return;
    }

    if (_lastValidFingerprint?.equals(settings) != true) {
      _lastValidFingerprint = settings;
      fingerprintListenable.value = settings;

      if (settings.refreshInterval != _config["refreshInterval"]) {
        _config["refreshInterval"] = settings.refreshInterval;
        _scheduleNextFetch();
      }
    }
  }

  void _updateMessageSetting(MessageSettings? settings) {
    if (settings == null) {
      messageListenable.value = null;
      return;
    }

    if (_lastValidMessage?.equals(settings) != true) {
      _lastValidMessage = settings;
      messageListenable.value = settings;
    }
  }
}
