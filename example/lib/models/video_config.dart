/// Video item configuration used in the demo playlist.
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
