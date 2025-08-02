import 'package:watchmate_app/common/models/hls_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class HlsVideoPlayer extends StatefulWidget {
  const HlsVideoPlayer({this.url, this.data, super.key});
  final HlsModel? data;
  final String? url;

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    final url = widget.data?.url ?? widget.url;
    if (url == null) return;

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
