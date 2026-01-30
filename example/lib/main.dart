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
  ChewieController? _chewieController;
  String _deviceId = '';

  int _currentIndex = 0;
  Key _playerKey = UniqueKey();

  /// Playlist
  final List<VideoConfig> _playlist = [
    // VideoConfig(
    //   title: 'SAB_SD',
    //   channelId: "SAB_SD",
    //   url: "http://103.204.167.124/hls/SAB_SD/index.m3u8",
    //   drmConfiguration: {
    //     'merchantId': 'abs',
    //     'appId': 'sigma_abs',
    //     'userId': 'G-R3VFD7QTQD',
    //     'sessionId':
    //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3OTY5MTksImV4cCI6MTc2ODgyMDMxOX0.rP6426MzOOoD_BwTxEqHJ7AWQWijONllihwPmHloWQs',
    //   },
    // ),
    VideoConfig(
      title: 'SONY_MAX',
      channelId: "SONY_MAX",
      url: "http://103.204.167.124/hls/SONY_MAX/index.m3u8",
      drmConfiguration: {
        'merchantId': 'abs',
        'appId': 'sigma_abs',
        'userId': 'G-R3VFD7QTQD',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3OTY5MTksImV4cCI6MTc2ODgyMDMxOX0.rP6426MzOOoD_BwTxEqHJ7AWQWijONllihwPmHloWQs',
      },
    ),
    VideoConfig(
      title: 'SONY_AATH',
      channelId: "SONY_AATH",
      url: "http://103.204.167.124/hls/SONY_AATH/index.m3u8",
      drmConfiguration: {
        'merchantId': 'abs',
        'appId': 'sigma_abs',
        'userId': 'G-R3VFD7QTQD',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3OTY5MTksImV4cCI6MTc2ODgyMDMxOX0.rP6426MzOOoD_BwTxEqHJ7AWQWijONllihwPmHloWQs',
      },
    ),
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
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg3OTY5MTksImV4cCI6MTc2ODgyMDMxOX0.rP6426MzOOoD_BwTxEqHJ7AWQWijONllihwPmHloWQs',
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
    _getDeviceId();
    SigmaVideoPlayer.init();
    SigmaFPM.instance.setConfig(
      apiBaseUrl: 'https://audit-drm-api-dev.sigmadrm.com',
      accessToken:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3NTA5OTEyMDYsImF1ZCI6IiIsInN1YiI6IiIsInBob25lIjoiMDk5NTk1MTc2MzIiLCJkZXZpY2VJZCI6IjIwZDY4ZTJjMTBkY2NjOTgiLCJjaGFubmVsSWQiOjEwMCwicGFja2FnZUlkIjoiYWFhYWFhYWEtYWFhYS1hYWFhLWFhYWEtYWFhYWFhYWFhYWFhIn0.8AsErZhZarJbzT2isIwSzfk8o3voqOVBhJuzRazmlZs',
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

    _createChewieController(_videoController!);
    setState(() {});
  }

  void _createChewieController(VideoPlayerController controller) {
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      fullScreenByDefault: false,
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

  Future<void> _getDeviceId() async {
    try {
      _deviceId = await SigmaVideoPlayer.getSigmaDeviceId();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error getting deviceId: $e");
    }
  }

  /// -------------------------
  /// UI
  /// -------------------------

  @override
  Widget build(BuildContext context) {
    final current = _playlist[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// =====================
          /// VIDEO PLAYER (BOTTOM)
          /// =====================
          Positioned.fill(
            child: Center(
              key: _playerKey,
              child:
                  _chewieController != null &&
                      _chewieController!
                          .videoPlayerController
                          .value
                          .isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const CircularProgressIndicator(),
            ),
          ),

          /// =====================
          /// OVERLAY UI (TOP)
          /// =====================
          Positioned(
            left: 16,
            right: 16,
            top: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    current.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Channel ID
                  Text(
                    'ChannelId: ${current.channelId}',
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  /// Device ID
                  Text(
                    'DeviceId: $_deviceId',
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _chewieController?.enterFullScreen();
                        },
                        child: const Text('Fullscreen'),
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: _nextVideo,
                        child: const Text('Next Video'),
                      ),
                    ],
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
