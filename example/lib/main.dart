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

  int _currentIndex = 0;
  Key _playerKey = UniqueKey();

  /// Playlist
  final List<VideoConfig> _playlist = [
    const VideoConfig(
      title: "Big bug bunny clear",
      channelId: "78980",
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    ),
    // VideoConfig(
    //   title: 'Big bug bunny - MultiDRM',
    //   channelId: "001",
    //   url:
    //       "https://sdrm-test.gviet.vn:9080/static/vod_staging/the_box/manifest.mpd",
    //   drmConfiguration: {
    //     "licenseServerUrl":
    //         "https://license-staging.sigmadrm.com/license/verify/widevine",
    //     "merchantId": "sctv",
    //     "appId": "RedTV",
    //     "userId": "flutter user id",
    //     "sessionId": "session id",
    //   },
    // ),
    VideoConfig(
      title: 'SANSAD_TV_HD',
      channelId: "100",
      url:
          "http://live.ano.xcomcdn.com/manifest/SANSAD_TV_HD/masterSANSAD_TV_HD.m3u8",
      drmConfiguration: {
        'merchantId': 'anoplay',
        'appId': 'anoplay_jwt',
        'userId': 'SUWGD2FJTR',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJTVVdHRDJGSlRSXCIsXCJtZXJjaGFudFwiOlwiYW5vcGxheVwiLFwiYXNzZXRcIjpcIlNBTlNBRF9UVl9IRFwiLFwibWFjSWRcIjpcIjk0MjZmZjc3YTNmOGY0NzdcIixcInN0b3JlTGljZW5zZVwiOmZhbHNlfSIsInVzZXJJZCI6IlNVV0dEMkZKVFIiLCJkcm1JZCI6IlNBTlNBRF9UVl9IRCIsImlhdCI6MTc2ODYxNTg4NSwiZXhwIjoxNzY4NjI2Njk1fQ.rXJMJeGB6orOpJJY7O3fGAEezhxMH_PiPQM-G8BmZ6c',
      },
    ),

    VideoConfig(
      title: 'INDIA_NEWS_UP',
      channelId: "123",
      url:
          "http://live.ano.xcomcdn.com/manifest/INDIA_NEWS_UP/masterINDIA_NEWS_UP.m3u8",
      drmConfiguration: {
        'merchantId': 'anoplay',
        'appId': 'anoplay_jwt',
        'userId': 'SUWGD2FJTR',
        'sessionId':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzZGkiOiJ7XCJ1c2VyXCI6XCJTVVdHRDJGSlRSXCIsXCJtZXJjaGFudFwiOlwiYW5vcGxheVwiLFwiYXNzZXRcIjpcIklORElBX05FV1NfVVBcIixcIm1hY0lkXCI6XCI5NDI2ZmY3N2EzZjhmNDc3XCIsXCJzdG9yZUxpY2Vuc2VcIjpmYWxzZX0iLCJ1c2VySWQiOiJTVVdHRDJGSlRSIiwiZHJtSWQiOiJJTkRJQV9ORVdTX1VQIiwiaWF0IjoxNzY4NjE1NzgzLCJleHAiOjE3Njg2MjY1OTN9.krgrMDPfGO83Fbsgkeubh4mVuZyQ8680unMsNjjndyg',
      },
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

  /// -------------------------
  /// UI
  /// -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_playlist[_currentIndex]?.title}; ChannelId: ${_playlist[_currentIndex]?.channelId}',
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              key: _playerKey,
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
        ],
      ),
    );
  }
}
