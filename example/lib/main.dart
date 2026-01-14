import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sigma_video_player/sigma_video_player.dart';

void main() {
  runApp(const App());
}

/// Root app
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sigma Player Demo',
      builder: (context, child) {
        return SigmaFPM.instance.buildOverlay(child: child ?? const SizedBox());
      },
      home: const MyApp(),
    );
  }
}

/// Video configuration model
class VideoConfig {
  final String url;
  final String customData; // Base64 JSON (DRM info)
  final String channelId;

  const VideoConfig({
    required this.url,
    required this.channelId,
    this.customData = "",
  });
}

/// My app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VideoPlayerController? _videoController;

  int _playerKey = 0;

  /// Playlist
  final List<VideoConfig> _playlist = [
    VideoConfig(
      channelId: "123",
      url:
          "https://sdrm-test.gviet.vn:9080/static/vod_production/big_bug_bunny/manifest.mpd",
      customData:
          "eyJtZXJjaGFudElkIjoic2lnbWFfcGFja2FnZXJfbGl0ZSIsImFwcElkIjoiZGVtbyIsInVzZXJJZCI6InVzZXIgaWQiLCJzZXNzaW9uSWQiOiJzZXNzaW9uIGlkIn0=",
    ),
    VideoConfig(
      channelId: "4567",
      url:
          "https://live-on-vng.sigmaott.com/manifest/vtv1/master.m3u8?manifestfilter=video_height%3A1-720",
      customData:
          "eyJtZXJjaGFudElkIjoidGh1ZG9qc2MiLCJhcHBJZCI6IlZUVmNhYk9OIiwic2Vzc2lvbklkIjoiZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnpaR2tpT2lKN1hDSjFjMlZ5WENJNlhDSkhMVkl6VmtaRU4xRlVVVVJjSWl4Y0ltMWxjbU5vWVc1MFhDSTZYQ0owYUhWa2IycHpZMXdpTEZ3aVlYTnpaWFJjSWpwY0luWjBkakZjSW4waUxDSjFjMlZ5U1dRaU9pSkhMVkl6VmtaRU4xRlVVVVFpTENKa2NtMUpaQ0k2SW5aMGRqRWlMQ0pwWVhRaU9qRTNOamMzTlRnME56Y3NJbVY0Y0NJNk1UYzJOemM0TVRnM04zMC5yRHpvZThTd0luZDNyUGtzNnRFNHBXQXphWVlZWEV1ODBmVVN2blpoRldRIiwidXNlcklkIjoiRy1SM1ZGRDdRVFFEIn0=",
    ),
    const VideoConfig(
      channelId: "78980",
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _playByConfig(_playlist[_currentIndex]);
    SigmaVideoPlayer.init();
    SigmaFPM.instance.setConfig(
      apiBaseUrl: 'https://audit-drm-api-dev.sigmadrm.com',
      accessToken:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3NTA5OTEyMDYsImF1ZCI6IiIsInN1YiI6IiIsInBob25lIjoiNzI5LTczOS05NDMyIiwiZGV2aWNlSWQiOiIwMTA3MDAxNDYyN2VlOTU3IiwiY2hhbm5lbElkIjoxMDAsInBhY2thZ2VJZCI6ImFhYWEifQ.lWJMlNFlr8ZPqIsDlav9g1O2AWFZknk-8XZOYt-Mjl8',
    );
    SigmaFPM.instance.start();
  }

  @override
  void dispose() {
    SigmaFPM.instance.stop();
    _disposePlayer();
    super.dispose();
  }

  /// -------------------------
  /// Utils
  /// -------------------------

  Map<String, String> _parseBase64Json(String base64String) {
    final decoded = utf8.decode(base64.decode(base64String));
    final Map<String, dynamic> jsonMap = json.decode(decoded);
    return jsonMap.map((k, v) => MapEntry(k, v?.toString() ?? ""));
  }

  Future<void> _disposePlayer() async {
    await _videoController?.dispose();
    _videoController = null;
  }

  /// -------------------------
  /// Player init
  /// -------------------------

  Future<void> _initializePlayer({
    required String url,
    required String merchantId,
    required String appId,
    required String userId,
    required String sessionId,
  }) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      drmConfiguration: {
        'merchantId': merchantId,
        'appId': appId,
        'userId': userId,
        'sessionId': sessionId,
      },
    );

    _videoController = controller;

    await controller.initialize();
    if (!mounted) return;

    await controller.play();

    setState(() {});
  }

  /// -------------------------
  /// Playlist control
  /// -------------------------

  Future<void> _playByConfig(VideoConfig config) async {
    String merchantId = "";
    String appId = "";
    String userId = "";
    String sessionId = "";

    if (config.customData.isNotEmpty) {
      final parsed = _parseBase64Json(config.customData);
      merchantId = parsed['merchantId'] ?? "";
      appId = parsed['appId'] ?? "";
      userId = parsed['userId'] ?? "";
      sessionId = parsed['sessionId'] ?? "";
    }

    await _disposePlayer();
    _playerKey++;

    SigmaFPM.instance.setChannelId(config.channelId);

    await _initializePlayer(
      url: config.url,
      merchantId: merchantId,
      appId: appId,
      userId: userId,
      sessionId: sessionId,
    );
  }

  void _changeVideo() {
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    _playByConfig(_playlist[_currentIndex]);
  }

  Future<void> _togglePlayPause() async {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    setState(() {});
  }

  /// -------------------------
  /// UI
  /// -------------------------

  Widget _buildPlayer() {
    final controller = _videoController;

    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    if (kIsWeb) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }

    return KeyedSubtree(
      key: ValueKey(_playerKey),
      child: JkVideoControlPanel(
        controller,
        showFullscreenButton: true,
        showVolumeButton: true,
      ),
    );
  }

  // Need to wrap SigmaFPM around child in Widget build(BuildContext context) {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 32),
          Expanded(child: Center(child: _buildPlayer())),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _togglePlayPause,
                child: Icon(
                  (_videoController?.value.isPlaying ?? false)
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _changeVideo,
                child: const Icon(Icons.skip_next),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
