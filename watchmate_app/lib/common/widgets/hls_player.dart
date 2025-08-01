import 'package:watchmate_app/services/api_service/api_routes.dart';
import 'package:watchmate_app/utils/network_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class HlsVideoPlayer extends StatefulWidget {
  final String resolution;
  final String filename;
  final String folder;

  const HlsVideoPlayer({
    this.filename = "index.m3u8",
    this.resolution = "f_320",
    required this.folder,
    super.key,
  });

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    final url =
        "${NetworkUtils.baseUrl}${ApiRoutes.stream.getStreamVideo(resolution: widget.resolution, filename: widget.filename, folder: widget.folder)}";

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          allowFullScreen: true,
          aspectRatio: 16 / 9,
          allowMuting: true,
          looping: false,
          autoPlay: true,
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
