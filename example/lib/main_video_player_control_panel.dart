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
  final String title;
  final String url;
  final Map<String, String> drmConfiguration;
  final String channelId;

  const VideoConfig({
    required this.title,
    required this.url,
    required this.channelId,
    this.drmConfiguration = const {},
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
  int _currentIndex = 0;

  /// Playlist
  final List<VideoConfig> _playlist = [
    VideoConfig(
      title: 'VTV1',
      channelId: "100",
      url:
          "https://live-on-akm.akamaized.net/manifest/vtv1/master.m3u8?manifestfilter=video_height%3A1-720",
      drmConfiguration: {
        'merchantId': 'thudojsc',
        'appId': 'VTVcabON',
        'userId': 'G-R3VFD7QTQD',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3ODY3NTUsImV4cCI6MTc2ODgxMDE1NX0.YF9PpTKGoQVU1NIulgAxjlmpiBidg88c-HIkJHrOL7k',
      },
    ),
    const VideoConfig(
      title: "Big Buck Bunny Clear",
      channelId: "78980",
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    ),
  ];

  @override
  void initState() {
    super.initState();

    SigmaVideoPlayer.init();

    SigmaFPM.instance.setConfig(
      apiBaseUrl: 'https://audit-drm-api-dev.sigmadrm.com',
      accessToken:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3NTA5OTEyMDYsImF1ZCI6IiIsInN1YiI6IiIsInBob25lIjoiMDkxODUxODI2MzUiLCJkZXZpY2VJZCI6IjIwZDY4ZTJjMTBkY2NjOTgiLCJjaGFubmVsSWQiOjEwMCwicGFja2FnZUlkIjoiYWFhYWFhYWEtYWFhYS1hYWFhLWFhYWEtYWFhYWFhYWFhYWFhIn0.XrTu8-ZGS2Lc7_1zW_mVcm2pnAXGRjUN-sWw1e9gylw',
    );

    SigmaFPM.instance.start();

    _playByConfig(_playlist[_currentIndex]);
  }

  @override
  void dispose() {
    SigmaFPM.instance.stop();
    _disposePlayer();
    super.dispose();
  }

  /// -------------------------
  /// Player utils
  /// -------------------------

  Future<void> _disposePlayer() async {
    await _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _initializePlayer({
    required String url,
    Map<String, String> drmConfiguration = const {},
  }) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      drmConfiguration: drmConfiguration,
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
    await _disposePlayer();

    SigmaFPM.instance.setChannelId(config.channelId);

    await _initializePlayer(
      url: config.url,
      drmConfiguration: config.drmConfiguration,
    );

    _playerKey++;
  }

  void _nextVideo() {
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
      return const Center(child: CircularProgressIndicator());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 32),
          Expanded(child: _buildPlayer()),
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
                onPressed: _nextVideo,
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
