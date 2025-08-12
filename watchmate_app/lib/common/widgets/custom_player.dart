import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({
    required this.thumbnailURL,
    required this.url,
    super.key,
  });

  final String thumbnailURL;
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
              allowFullScreen: true,
              aspectRatio: _aspectRatio ?? (16 / 9),
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
    final loading =
        _chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized;

    return AspectRatio(
      aspectRatio: _aspectRatio ?? (16 / 9),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CacheImage(url: widget.thumbnailURL).hero(widget.thumbnailURL),
          AnimatedSwitcher(
            duration: 300.millis,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Chewie(controller: _chewieController!),
          ),
        ],
      ),
    );
  }
}
