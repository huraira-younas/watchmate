import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Timer;

class CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback toggleScreen;
  final bool isFullScreen;
  final double seekPad;
  final bool isOwner;
  final String title;

  const CustomVideoControls({
    required this.isFullScreen,
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

  bool _showSeekOverlay = false;
  bool _controlsVisible = true;
  String? _seekOverlayText;
  Timer? _overlayTimer;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoUpdate);
    _startHideTimer();
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!mounted) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  bool _toggleControls() {
    final oc = _controlsVisible;
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _startHideTimer();
    return oc;
  }

  void _seekBy(Duration offset) {
    final currentPos = controller.value.position;
    final targetPos = currentPos + offset;
    final duration = controller.value.duration;

    final clampedPos = targetPos < Duration.zero
        ? Duration.zero
        : (targetPos > duration ? duration : targetPos);

    controller.seekTo(clampedPos);

    _seekOverlayText = offset.inSeconds > 0
        ? "+ ${offset.inSeconds.abs()}s"
        : "- ${offset.inSeconds.abs()}s";

    setState(() => _showSeekOverlay = true);

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showSeekOverlay = false);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoUpdate);
    _overlayTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControls,
      onDoubleTapDown: (details) {
        if (!widget.isOwner) return;
        final box = context.findRenderObject() as RenderBox;
        final tapPos = box.globalToLocal(details.globalPosition);

        _seekBy(
          tapPos.dx < box.size.width / 2
              ? const Duration(seconds: -10)
              : const Duration(seconds: 10),
        );
      },
      child: Stack(
        children: <Widget>[
          AnimatedOpacity(
            duration: 200.millis,
            opacity: _controlsVisible ? 1 : 0,
            child: _VideoControlsOverlay(
              onToggleScreen: widget.toggleScreen,
              isFullScreen: widget.isFullScreen,
              formatDuration: _formatDuration,
              seekPad: widget.seekPad,
              isOwner: widget.isOwner,
              value: controller.value,
              controller: controller,
              title: widget.title,
              onSeek: (dur) {
                if (!_toggleControls()) return;
                _seekBy(dur);
              },
              onPlayPause: () {
                if (!_toggleControls()) return;

                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
                _startHideTimer();
              },
            ),
          ),
          if (_seekOverlayText != null)
            _SeekOverlay(text: _seekOverlayText!, visible: _showSeekOverlay),
        ],
      ),
    );
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  final String Function(Duration) formatDuration;
  final VideoPlayerController controller;
  final VoidCallback onToggleScreen;
  final Function(Duration) onSeek;
  final VoidCallback onPlayPause;
  final VideoPlayerValue value;
  final bool isFullScreen;
  final double seekPad;
  final String title;
  final bool isOwner;

  const _VideoControlsOverlay({
    required this.onToggleScreen,
    required this.formatDuration,
    this.isFullScreen = false,
    required this.onPlayPause,
    required this.controller,
    required this.seekPad,
    required this.isOwner,
    required this.onSeek,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (isFullScreen)
                BackIcon(
                  color: theme.iconTheme.color ?? Colors.black,
                  onBackPress: onToggleScreen,
                ),
              MyText(
                size: isFullScreen ? AppConstants.title : AppConstants.subtitle,
                overflow: TextOverflow.ellipsis,
                family: AppFonts.bold,
                color: Colors.white,
                text: title,
                maxLines: 2,
              ).padAll(12).align(align: Alignment.topLeft).expanded(),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MyText(
                    text: formatDuration(value.position),
                    family: AppFonts.medium,
                    color: Colors.white,
                    size: 11,
                  ),
                  MyText(
                    text: formatDuration(value.duration),
                    family: AppFonts.medium,
                    color: Colors.white,
                    size: 11,
                  ),
                ],
              ).padSym(h: 10),
              VideoProgressIndicator(
                controller,
                allowScrubbing: isOwner,
                colors: VideoProgressColors(
                  bufferedColor: theme.primaryColorDark.withValues(alpha: 0.4),
                  backgroundColor: theme.canvasColor,
                  playedColor: theme.primaryColor,
                ),
              ).padSym(h: seekPad),
              Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: !isOwner
                        ? <Widget>[]
                        : <Widget>[
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: () {
                                onSeek(const Duration(seconds: -10));
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: onPlayPause,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: () {
                                onSeek(const Duration(seconds: 10));
                              },
                            ),
                          ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: onToggleScreen,
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

class _SeekOverlay extends StatelessWidget {
  const _SeekOverlay({required this.text, required this.visible});
  final bool visible;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: 150.millis,
        opacity: visible ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black54,
          ),
          child: MyText(text: text, size: 20),
        ).center(),
      ),
    );
  }
}
