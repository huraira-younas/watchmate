import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class HlsVideoPlayer extends StatefulWidget {
  final String resolution;
  final String folder;

  const HlsVideoPlayer({
    super.key,
    required this.folder,
    this.resolution = "f_720",
  });

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();

    final String url =
        "http://yourdomain.com/video/${widget.folder}/${widget.resolution}/index.m3u8";

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      useAsmsSubtitles: false,
      useAsmsAudioTracks: false,
    );

    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _controller),
    );
  }
}
