import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      title: 'Sigma DRM',
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
  ChewieController? _chewieController;

  int _currentIndex = 0;
  Key _playerKey = UniqueKey();

  /// Playlist
  final List<VideoConfig> _playlist = [
    VideoConfig(
      title: 'SPORTS_TEN_5_HD',
      channelId: "123",
      url:
          "https://live-on-akm.akamaized.net/manifest/vtv1/master.m3u8?manifestfilter=video_height%3A1-720",
      drmConfiguration: {
        'merchantId': 'thudojsc',
        'appId': 'VTVcabON',
        'userId': 'G-R3VFD7QTQD',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3MzE2MzYsImV4cCI6MTc2ODc1NTAzNn0.2lYW9meqp2d3iyObqMVeIbijYECp3pYt8L6Y93wMBig',
      },
    ),
    const VideoConfig(
      title: "Big Buck Bunny",
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
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3NTA5OTEyMDYsImF1ZCI6IiIsInN1YiI6IiIsInBob25lIjoiMDkxODUxODI2MzUiLCJkZXZpY2VJZCI6ImU5MTIzNzI4NGJmNGI3MWIiLCJjaGFubmVsSWQiOjEwMCwicGFja2FnZUlkIjoiYWFhYWFhYWEtYWFhYS1hYWFhLWFhYWEtYWFhYWFhYWFhYWFhIn0.ZhHS6_blLC-nGv5XWvoIoE3XAuM_5rNsV_B2a4hr5PI',
    );
    SigmaFPM.instance.start();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    initializePlayer();
  }

  @override
  void dispose() {
    SigmaFPM.instance.stop();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _disposePlayer();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    await _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
  }

  Future<void> initializePlayer() async {
    await _disposePlayer();

    final config = _playlist[_currentIndex];
    SigmaFPM.instance.setChannelId(config.channelId);

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(config.url),
      drmConfiguration: config.drmConfiguration,
      viewType: VideoViewType.textureView,
    );

    await _videoController!.initialize();
    if (!mounted) return;

    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: (context) {
              Navigator.pop(context); // Close the menu
              _nextVideo();
            },
            iconData: Icons.skip_next,
            title: 'Next Video',
          ),
        ];
      },
    );
  }

  Future<void> _nextVideo() async {
    _playerKey = UniqueKey();
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await initializePlayer();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _nextVideo();
      return true;
    }
    return false;
  }

  /// -------------------------
  /// UI
  /// -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            key: _playerKey,
            child:
                _chewieController?.videoPlayerController.value.isInitialized ==
                    true
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${_playlist[_currentIndex].title}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'ChannelId: ${_playlist[_currentIndex].channelId}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'URL: ${_playlist[_currentIndex].url}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Press Arrow Up to switch video',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
