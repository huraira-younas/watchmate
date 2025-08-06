import 'package:watchmate_app/common/services/api_service/api_routes.dart';
import 'package:watchmate_app/extensions/context_extensions.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({required this.url, super.key});
  final String url;

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    final url = ApiRoutes.stream.getStreamVideo(url: widget.url);
    Logger.info(tag: "PLAYING", message: Uri.parse(url));

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
    final theme = context.theme;
    final loading =
        _chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: loading
          ? ColoredBox(
              color: theme.cardColor,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Chewie(controller: _chewieController!),
    );
  }
}
