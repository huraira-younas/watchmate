import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    required this.thumbnailURL,
    required this.tagPrefix,
    required this.url,
    super.key,
  });

  final String thumbnailURL;
  final String tagPrefix;
  final String url;

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();

    final cleanUrl = widget.url.replaceAll('"', '');
    Logger.info(tag: "PLAYING", message: Uri.parse(cleanUrl));

    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(cleanUrl))
          ..initialize().then((_) {
            _aspectRatio =
                _videoPlayerController.value.size.width /
                _videoPlayerController.value.size.height;

            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              aspectRatio: _aspectRatio ?? (16 / 9),
              allowFullScreen: true,
              showOptions: false,
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

    final double maxHeight = context.screenHeight * 0.43;

    final double arHeight = context.screenWidth / (_aspectRatio ?? (16 / 9));
    final double finalHeight = arHeight < maxHeight ? arHeight : maxHeight;

    return AnimatedContainer(
      height: loading ? arHeight : finalHeight,
      width: context.screenWidth,
      duration: 100.millis,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(widget.thumbnailURL)),
        color: theme.cardColor.withValues(alpha: 0.2),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : AspectRatio(
              aspectRatio: _aspectRatio ?? (16 / 9),
              child: Chewie(controller: _chewieController!),
            ),
    ).hero("${widget.tagPrefix}:${widget.thumbnailURL}");
  }
}
