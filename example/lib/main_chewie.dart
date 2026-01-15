import 'package:flutter/material.dart';

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
  final Map<String, String> drmConfiguration;
  final String channelId;

  const VideoConfig({
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

  /// Playlist
  final List<VideoConfig> _playlist = [
    VideoConfig(
      channelId: "123",
      url:
          "https://sdrm-test.gviet.vn:9080/static/vod_production/big_bug_bunny/manifest.mpd",
      drmConfiguration: {
        'merchantId': 'sigma_packager_lite',
        'appId': 'demo',
        'userId': 'user id',
        'sessionId': 'session id',
      },
    ),
    VideoConfig(
      channelId: "4567",
      url:
          "https://live-on-akm.akamaized.net/manifest/vtv1/master.m3u8?manifestfilter=video_height%3A1-720",
      drmConfiguration: {
        'merchantId': 'thudojsc',
        'appId': 'VTVcabON',
        'userId': 'G-R3VFD7QTQD',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJHLVIzVkZEN1FUUURcIixcIm1lcmNoYW50XCI6XCJ0aHVkb2pzY1wiLFwiYXNzZXRcIjpcInZ0djFcIn0iLCJ1c2VySWQiOiJHLVIzVkZEN1FUUUQiLCJkcm1JZCI6InZ0djEiLCJpYXQiOjE3Njg0NDU3ODUsImV4cCI6MTc2ODQ2OTE4NX0.kba0PyFy6OdZ_QyZgFFSwmk_ygkhM3Nn5vtDyINGFso',
      },
    ),
    const VideoConfig(
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
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3NTA5OTEyMDYsImF1ZCI6IiIsInN1YiI6IiIsInBob25lIjoiNzI5LTczOS05NDMyIiwiZGV2aWNlSWQiOiIwMTA3MDAxNDYyN2VlOTU3IiwiY2hhbm5lbElkIjoxMDAsInBhY2thZ2VJZCI6ImFhYWEifQ.lWJMlNFlr8ZPqIsDlav9g1O2AWFZknk-8XZOYt-Mjl8',
    );
    SigmaFPM.instance.start();
    initializePlayer();
  }

  @override
  void dispose() {
    SigmaFPM.instance.stop();
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
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await initializePlayer();
  }

  /// -------------------------
  /// UI
  /// -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sigma Player Demo')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child:
                  _chewieController != null &&
                      _chewieController!
                          .videoPlayerController
                          .value
                          .isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _chewieController?.enterFullScreen();
                },
                child: const Text('Fullscreen'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _nextVideo,
                child: const Text('Next Video'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
