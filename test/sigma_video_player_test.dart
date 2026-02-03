import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigma_video_player/sigma_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVideoPlayerPlatform
    with MockPlatformInterfaceMixin
    implements VideoPlayerPlatform {
  @override
  Widget buildView(int textureId) {
    throw UnimplementedError();
  }

  @override
  Future<void> configure(
    int textureId,
    String merchantId,
    String appId,
    String userId,
    String sessionId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<int?> create(DataSource dataSource) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose(int textureId) {
    throw UnimplementedError();
  }

  @override
  Future<Duration> getPosition(int textureId) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    throw UnimplementedError();
  }

  @override
  Future<void> pause(int textureId) {
    throw UnimplementedError();
  }

  @override
  Future<void> play(int textureId) {
    throw UnimplementedError();
  }

  @override
  Future<void> seekTo(int textureId, Duration position) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    throw UnimplementedError();
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    throw UnimplementedError();
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(int textureId, double volume) {
    throw UnimplementedError();
  }

  @override
  Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) {
    throw UnimplementedError();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    throw UnimplementedError();
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    throw UnimplementedError();
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) {
    throw UnimplementedError();
  }

  @override
  Future<List<VideoAudioTrack>> getAudioTracks(int playerId) {
    throw UnimplementedError();
  }

  @override
  Future<String> getSigmaDeviceId() {
    throw UnimplementedError();
  }

  @override
  Future<void> selectAudioTrack(int playerId, String trackId) {
    throw UnimplementedError();
  }

  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) {
    throw UnimplementedError();
  }

  @override
  bool isAudioTrackSupportAvailable() {
    return false;
  }
}

void main() {
  test('getPlatformVersion', () async {
    MockVideoPlayerPlatform fakePlatform = MockVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakePlatform;

    expect(await fakePlatform.hashCode, '42');
  });
}
