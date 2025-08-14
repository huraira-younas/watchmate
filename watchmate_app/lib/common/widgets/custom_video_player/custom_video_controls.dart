import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback toggleScreen;
  final double seekPad;
  final bool isOwner;
  final String title;

  const CustomVideoControls({
    required this.toggleScreen,
    required this.controller,
    required this.seekPad,
    required this.isOwner,
    required this.title,
    super.key,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  late final controller = widget.controller;
  void _seekBy(Duration offset) {
    final currentPos = controller.value.position;
    final targetPos = currentPos + offset;

    final duration = controller.value.duration;
    final clampedPos = targetPos < Duration.zero
        ? Duration.zero
        : (targetPos > duration ? duration : targetPos);

    controller.seekTo(clampedPos);
  }

  String _formatDuration(Duration duration) {
    twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_update);
  }

  void _update() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    setState(() {});
  });

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final theme = context.theme;

    return ColoredBox(
      color: Colors.black45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: MyText(
                  overflow: TextOverflow.ellipsis,
                  family: AppFonts.bold,
                  text: widget.title,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: widget.toggleScreen,
              ),
            ],
          ).padSym(h: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              MyText(
                text: "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                family: AppFonts.medium,
                size: 11,
              ).padSym(h: 20),
              VideoProgressIndicator(
                controller,
                allowScrubbing: widget.isOwner,
                colors: VideoProgressColors(
                  bufferedColor: theme.primaryColorDark.withValues(alpha: 0.4),
                  backgroundColor: theme.canvasColor,
                  playedColor: theme.primaryColor,
                ),
              ).padSym(h: widget.seekPad),

              if (widget.isOwner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () => _seekBy(const Duration(seconds: -10)),
                    ),
                    IconButton(
                      icon: Icon(
                        value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () => _seekBy(const Duration(seconds: 10)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
